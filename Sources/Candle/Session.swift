import CandleSession
import Foundation
import HTTPTypes
import KeychainSwift
import OpenAPIRuntime
import OpenAPIURLSession

public typealias ConnectionResult = CandleSession.ConnectionResult

// FIXME: Refactor error handling to not use try!
public actor Session {

    private static var isOpen = false

    // FIXME: Expose actual Candle User from POST/PUT call
    let appUser: Models.AppUser

    private let deviceConnection: DeviceConnection
    private let client: Client

    private init(deviceConnection: DeviceConnection, client: Client, appUser: Models.AppUser) {
        self.deviceConnection = deviceConnection
        self.client = client
        self.appUser = appUser

        Self.isOpen = true
    }

    private static func updateUser(
        appUser: Models.AppUser, authorizationToken: String, clientTransport: URLSessionTransport
    ) async throws(Models.UpdateUser.Error) -> String {
        let authorizationMiddleware = AuthorizationMiddleware(
            authorizationToken: authorizationToken)
        let client = Client(
            serverURL: httpAPIURL,
            transport: clientTransport,
            middlewares: [HeaderEncodingMiddleware(), authorizationMiddleware]
        )

        let response: Models.UpdateUser.Output
        do {
            response = try await client.putUsers(
                body: .json(appUser)
            )
        } catch {
            log(
                .error, event: "Session Creation Failed",
                metadata: [
                    "failureReason": "network_error",
                    "networkCall": "putUsers",
                    "errorDescription": error.localizedDescription,
                ])
            throw .networkError(error as? URLError)
        }
        switch response {
        case .noContent:
            return authorizationToken

        case .unauthorized(let data):
            throw .unauthorized(try! data.body.json)
        case .forbidden(let data): throw .forbidden(try! data.body.json)
        case .notFound(let data): throw .notFound(try! data.body.json)
        case .conflict(let data): throw .conflict(try! data.body.json)
        case .unprocessableContent(let data):
            throw .unprocessableContent(try! data.body.json)
        case .internalServerError(let data):
            throw .internalServerError(try! data.body.json)
        case .undocumented(let statusCode, _):
            throw .unexpectedStatusCode(statusCode)
        }
    }

    private static func createUser(appUser: Models.AppUser, clientTransport: URLSessionTransport)
        async throws(Models.CreateUser.Error) -> String
    {
        let response: Models.CreateUser.Output
        do {
            let client = Client(
                serverURL: httpAPIURL,
                transport: clientTransport,
                middlewares: [HeaderEncodingMiddleware()]
            )
            response = try await client.postUsers(
                headers: .init(
                    // FIXME: Get this from an analytics SDK
                    anonymousUserId: "FIXME_FROM_ANALYTICS_SDK"
                ),
                body: .json(appUser)
            )
        } catch {
            log(
                .error, event: "Session Creation Failed",
                metadata: [
                    "failureReason": "network_error",
                    "networkCall": "postUsers",
                    "errorDescription": error.localizedDescription,
                ])
            throw .networkError(error as? URLError)
        }
        switch response {
        case .created(let created):
            // FIXME: Have Bearer token (both request & response) handled by OpenAPI generated code
            guard
                created.headers.authorization.starts(
                    with: CandleSession.Constants.API.authorizationHeaderValuePrefix)
            else {
                log(
                    .error, event: "Session Creation Failed",
                    metadata: [
                        "failureReason": "invalid_authorization_header",
                        "networkCall": "postUsers",
                    ])
                throw .missingAuthorizationToken
            }
            let authorizationToken = String(
                created.headers.authorization.dropFirst(
                    CandleSession.Constants.API.authorizationHeaderValuePrefix.count))
            guard
                KeychainSwift().set(
                    authorizationToken,
                    forKey: Constants.Keychain.authorizationTokenKey)
            else {
                log(
                    .error, event: "Session Creation Failed",
                    metadata: [
                        "failureReason": "keychain_error",
                        "operation": "set",
                    ])
                throw .keychainError
            }
            return authorizationToken

        case .unauthorized(let data): throw .unauthorized(try! data.body.json)
        case .forbidden(let data): throw .forbidden(try! data.body.json)
        case .notFound(let data): throw .notFound(try! data.body.json)
        case .unprocessableContent(let data):
            throw .unprocessableContent(try! data.body.json)
        case .tooManyRequests(let data):
            throw .tooManyRequests(try! data.body.json)
        case .internalServerError(let data):
            throw .internalServerError(try! data.body.json)
        case .undocumented(let statusCode, _):
            throw .unexpectedStatusCode(statusCode)
        }
    }

    public static func open(
        for appUser: Models.AppUser,
        onClose: (@escaping @Sendable (ConnectionResult) -> Void) = { _ in }
    )
        async throws(Models.OpenSession.Error)
        -> Session
    {
        guard !isOpen else {
            log(
                .error, event: "Session Creation Failed",
                metadata: ["failureReason": "already_open"])
            throw .sessionAlreadyOpen
        }

        let urlSessionConfiguration = URLSessionConfiguration.default
        #if os(macOS)
            // FIXME: Automatically enable & configure this if Proxyman is running
            let proxyIPAddress: String? = nil
            let proxyPort = 9090

            if let proxyIPAddress {
                urlSessionConfiguration.connectionProxyDictionary = [
                    kCFNetworkProxiesHTTPEnable: true,
                    kCFNetworkProxiesHTTPProxy: proxyIPAddress,
                    kCFNetworkProxiesHTTPPort: proxyPort,
                    kCFNetworkProxiesHTTPSEnable: true,
                    kCFNetworkProxiesHTTPSProxy: proxyIPAddress,
                    kCFNetworkProxiesHTTPSPort: proxyPort,
                ]
                log(
                    .debug, event: "Network Proxy Configured",
                    metadata: [
                        "ipAddress": proxyIPAddress,
                        "port": String(proxyPort),
                    ])
            }
        #endif

        let urlSession = URLSession(
            configuration: urlSessionConfiguration,
            delegate: PinnedSessionDelegate(),
            delegateQueue: nil)
        let clientTransport = URLSessionTransport(
            configuration: URLSessionTransport.Configuration(session: urlSession))
        let headerEncodingMiddleware = HeaderEncodingMiddleware()

        let authorizationToken: String
        if let _authorizationToken = KeychainSwift().get(
            Constants.Keychain.authorizationTokenKey)
        {
            do throws(Models.UpdateUser.Error) {
                authorizationToken = try await updateUser(
                    appUser: appUser, authorizationToken: _authorizationToken,
                    clientTransport: clientTransport)
            } catch {
                throw .updateUserError(error)
            }
        } else {
            do throws(Models.CreateUser.Error) {
                authorizationToken = try await createUser(
                    appUser: appUser, clientTransport: clientTransport)
            } catch {
                log(
                    .error, event: "Session Creation Failed",
                    metadata: [
                        "failureReason": "network_error",
                        "networkCall": "postUsers",
                        "errorDescription": error.localizedDescription,
                    ])
                throw .createUserError(error)
            }
        }

        guard
            let deviceConnection = await DeviceConnection.open(
                using: urlSessionConfiguration,
                authorizationToken: authorizationToken,
                onClose: { result in
                    isOpen = false
                    onClose(result)
                }
            )
        else {
            throw .deviceConnectionError
        }

        let authorizationMiddleware = AuthorizationMiddleware(
            authorizationToken: authorizationToken)
        return Session(
            deviceConnection: deviceConnection,
            client: Client(
                serverURL: httpAPIURL,
                transport: URLSessionTransport(
                    configuration: URLSessionTransport.Configuration(session: urlSession)),
                middlewares: [headerEncodingMiddleware, authorizationMiddleware]
            ),
            appUser: appUser
        )
    }

    public func deleteUser()
        async throws(Models.DeleteUser.Error)
    {
        let response: Models.DeleteUser.Output
        do {
            response = try await client.deleteUsers(
                body: .json(appUser)
            )
        } catch {
            log(
                .error, event: "Session Destruction Failed",
                metadata: [
                    "failureReason": "network_error",
                    "networkCall": "deleteUsers",
                    "errorDescription": error.localizedDescription,
                ])
            throw .networkError(error as? URLError)
        }

        guard KeychainSwift().delete(Constants.Keychain.authorizationTokenKey) else {
            log(
                .error, event: "Session Destruction Failed",
                metadata: [
                    "failureReason": "keychain_error",
                    "operation": "set",
                ])
            throw .keychainError
        }

        switch response {
        case .noContent: break

        case .unauthorized(let error): throw .unauthorized(try! error.body.json)
        case .forbidden(let error): throw .forbidden(try! error.body.json)
        case .notFound(let error): throw .notFound(try! error.body.json)
        case .unprocessableContent(let error): throw .unprocessableContent(try! error.body.json)
        case .internalServerError(let error): throw .internalServerError(try! error.body.json)
        case .undocumented(let statusCode, _): throw .unexpectedStatusCode(statusCode)
        }
    }

    public func linkAccount(request: Models.LinkRequest)
        async throws(Models.LinkAccount.Error)
        -> Models.LinkAccount.Result
    {
        let response: Models.LinkAccount.Output
        do {
            response = try await client.postLinkedAccounts(body: .json(request))
        } catch {
            throw .networkError(error as? URLError)
        }
        switch response {
        case .created(let created): return .linked(try! created.body.json)
        case .preconditionRequired(let error): return .mfaRequired(try! error.body.json)

        case .unauthorized(let error): throw .unauthorized(try! error.body.json)
        case .notFound(let error): throw .notFound(try! error.body.json)
        case .conflict(let error): throw .conflict(try! error.body.json)
        case .unprocessableContent(let error): throw .unprocessableContent(try! error.body.json)
        case .internalServerError(let error): throw .internalServerError(try! error.body.json)
        case .undocumented(let statusCode, _): throw .unexpectedStatusCode(statusCode)
        }
    }

    public func unlinkAccount(linkedAccountID: Models.LinkedAccountID)
        async throws(Models.UnlinkAccount.Error)
    {
        let response: Models.UnlinkAccount.Output
        do {
            response = try await client.deleteLinkedAccount(
                path: .init(linkedAccountID: linkedAccountID)
            )
        } catch {
            throw .networkError(error as? URLError)
        }
        switch response {
        case .noContent: break

        case .unauthorized(let error): throw .unauthorized(try! error.body.json)
        case .notFound(let error): throw .notFound(try! error.body.json)
        case .conflict(let error): throw .conflict(try! error.body.json)
        case .unprocessableContent(let error): throw .unprocessableContent(try! error.body.json)
        case .internalServerError(let error): throw .internalServerError(try! error.body.json)
        case .undocumented(let statusCode, _): throw .unexpectedStatusCode(statusCode)
        }
    }

    public func getLinkedAccounts()
        async throws(Models.GetLinkedAccounts.Error)
        -> [Models.LinkedAccount]
    {
        let response: Models.GetLinkedAccounts.Output
        do {
            response = try await client.getLinkedAccounts()
        } catch {
            throw .networkError(error as? URLError)
        }

        switch response {
        case .ok(let ok): return try! ok.body.json

        case .unauthorized(let error): throw .unauthorized(try! error.body.json)
        case .notFound(let error): throw .notFound(try! error.body.json)
        case .unprocessableContent(let error): throw .unprocessableContent(try! error.body.json)
        case .internalServerError(let error): throw .internalServerError(try! error.body.json)
        case .undocumented(let statusCode, _): throw .unexpectedStatusCode(statusCode)
        }
    }

    public func getFiatAccounts(query: Models.GetFiatAccounts.Input.Query = .init())
        async throws(Models.GetFiatAccounts.Error)
        -> [Models.PrimaryFiatHoldingAccount]
    {
        let response: Models.GetFiatAccounts.Output
        do {
            response = try await client.getLinkedAccountsFiatHoldingAccounts(query: query)
        } catch {
            throw .networkError(error as? URLError)
        }

        switch response {
        case .ok(let ok): return try! ok.body.json

        case .unauthorized(let error): throw .unauthorized(try! error.body.json)
        case .notFound(let error): throw .notFound(try! error.body.json)
        case .unprocessableContent(let error): throw .unprocessableContent(try! error.body.json)
        case .internalServerError(let error): throw .internalServerError(try! error.body.json)
        case .undocumented(let statusCode, _): throw .unexpectedStatusCode(statusCode)
        }
    }

    public func getActivity(query: Models.GetActivity.Input.Query = .init())
        async throws(Models.GetActivity.Error)
        -> [Models.PortfolioActivityItem]
    {
        let response: Models.GetActivity.Output
        do {
            response = try await client.getLinkedAccountsActivity(query: query)
        } catch {
            throw .networkError(error as? URLError)
        }

        switch response {
        case .ok(let ok): return try! ok.body.json

        case .unauthorized(let error): throw .unauthorized(try! error.body.json)
        case .notFound(let error): throw .notFound(try! error.body.json)
        case .unprocessableContent(let error): throw .unprocessableContent(try! error.body.json)
        case .internalServerError(let error): throw .internalServerError(try! error.body.json)
        case .undocumented(let statusCode, _): throw .unexpectedStatusCode(statusCode)
        }
    }

    deinit {
        Self.isOpen = false
    }
}
