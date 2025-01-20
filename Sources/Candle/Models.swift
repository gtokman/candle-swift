import Foundation

public typealias Models = Components.Schemas

// MARK: HTTP API

extension Models {
    public typealias CreateUser = Operations.PostUsers
    public typealias UpdateUser = Operations.PutUsers
    public typealias DeleteUser = Operations.DeleteUsers
    public typealias LinkAccount = Operations.PostLinkedAccounts
    public typealias UnlinkAccount = Operations.DeleteLinkedAccount
    public typealias GetLinkedAccounts = Operations.GetLinkedAccounts
    public typealias GetFiatAccounts = Operations.GetLinkedAccountsFiatHoldingAccounts
    public typealias GetActivity = Operations.GetLinkedAccountsActivity

    public enum OpenSession {
        public enum Error: Swift.Error, Equatable {
            case deviceConnectionError
            case sessionAlreadyOpen

            case createUserError(Models.CreateUser.Error)
            case updateUserError(Models.UpdateUser.Error)
        }
    }
}

extension Models.CreateUser {
    public enum Error: Swift.Error, Equatable {
        case networkError(URLError?)
        case unexpectedStatusCode(Int)
        case missingAuthorizationToken
        case keychainError

        case unauthorized(Output.Unauthorized.Body.JsonPayload)
        case forbidden(Output.Forbidden.Body.JsonPayload)
        case notFound(Output.NotFound.Body.JsonPayload)
        case unprocessableContent(Output.UnprocessableContent.Body.JsonPayload)
        case tooManyRequests(Output.TooManyRequests.Body.JsonPayload)
        case internalServerError(Output.InternalServerError.Body.JsonPayload)
    }
}

extension Models.UpdateUser {
    public enum Error: Swift.Error, Equatable {
        case networkError(URLError?)
        case unexpectedStatusCode(Int)

        case unauthorized(Output.Unauthorized.Body.JsonPayload)
        case forbidden(Output.Forbidden.Body.JsonPayload)
        case notFound(Output.NotFound.Body.JsonPayload)
        case conflict(Output.Conflict.Body.JsonPayload)
        case unprocessableContent(Output.UnprocessableContent.Body.JsonPayload)
        case internalServerError(Output.InternalServerError.Body.JsonPayload)
    }
}

extension Models.DeleteUser {
    public enum Error: Swift.Error, Equatable {
        case networkError(URLError?)
        case unexpectedStatusCode(Int)
        case keychainError

        case unauthorized(Output.Unauthorized.Body.JsonPayload)
        case forbidden(Output.Forbidden.Body.JsonPayload)
        case notFound(Output.NotFound.Body.JsonPayload)
        case unprocessableContent(Output.UnprocessableContent.Body.JsonPayload)
        case internalServerError(Output.InternalServerError.Body.JsonPayload)
    }
}

extension Models.LinkAccount {
    public enum Result: Sendable, Equatable {
        case linked(Models.LinkedAccount)
        case mfaRequired(Models.MFARequest)
    }

    public enum Error: Swift.Error, Equatable {
        case networkError(URLError?)
        case unexpectedStatusCode(Int)

        case unauthorized(Output.Unauthorized.Body.JsonPayload)
        case notFound(Output.NotFound.Body.JsonPayload)
        case conflict(Output.Conflict.Body.JsonPayload)
        case unprocessableContent(Output.UnprocessableContent.Body.JsonPayload)
        case internalServerError(Output.InternalServerError.Body.JsonPayload)
    }
}

extension Models.UnlinkAccount {
    public enum Error: Swift.Error, Equatable {
        case networkError(URLError?)
        case unexpectedStatusCode(Int)

        case unauthorized(Output.Unauthorized.Body.JsonPayload)
        case notFound(Output.NotFound.Body.JsonPayload)
        case conflict(Output.Conflict.Body.JsonPayload)
        case unprocessableContent(Output.UnprocessableContent.Body.JsonPayload)
        case internalServerError(Output.InternalServerError.Body.JsonPayload)
    }
}

extension Models.GetLinkedAccounts {
    public enum Error: Swift.Error, Equatable {
        case networkError(URLError?)
        case unexpectedStatusCode(Int)

        case unauthorized(Output.Unauthorized.Body.JsonPayload)
        case notFound(Output.NotFound.Body.JsonPayload)
        case unprocessableContent(Output.UnprocessableContent.Body.JsonPayload)
        case internalServerError(Output.InternalServerError.Body.JsonPayload)
    }
}

extension Models.GetFiatAccounts {
    public enum Error: Swift.Error, Equatable {
        case networkError(URLError?)
        case unexpectedStatusCode(Int)

        case unauthorized(Output.Unauthorized.Body.JsonPayload)
        case notFound(Output.NotFound.Body.JsonPayload)
        case unprocessableContent(Output.UnprocessableContent.Body.JsonPayload)
        case internalServerError(Output.InternalServerError.Body.JsonPayload)
    }
}

extension Models.GetActivity {
    public enum Error: Swift.Error, Equatable {
        case networkError(URLError?)
        case unexpectedStatusCode(Int)

        case unauthorized(Output.Unauthorized.Body.JsonPayload)
        case notFound(Output.NotFound.Body.JsonPayload)
        case unprocessableContent(Output.UnprocessableContent.Body.JsonPayload)
        case internalServerError(Output.InternalServerError.Body.JsonPayload)
    }
}

extension Models.ProviderCredentialsRequest {
    public init(credentials: Models.ProviderCredentials) {
        self.init(step: .credentials, credentials: credentials)
    }
}
extension Models.MFAResponseRequest {
    public init(response: Models.MFAResponse) {
        self.init(step: .mfa, response: response)
    }
}
extension Models.DemoProviderCredentials {
    public init(username: String) {
        self.init(provider: .demo, username: username)
    }
}
extension Models.RobinhoodProviderCredentials {
    public init(username: String, password: String) {
        self.init(provider: .robinhood, username: username, password: password)
    }
}
extension Models.CashAppProviderCredentials {
    public init(alias: Models.CashAppProviderCredentials.AliasPayload, pin: String) {
        self.init(provider: .cashApp, alias: alias, pin: pin)
    }
}
extension Models.VenmoProviderCredentials {
    public init(username: String, password: String) {
        self.init(provider: .venmo, username: username, password: password)
    }
}
extension Models.AppleProviderCredentials {
    public init() {
        self.init(provider: .apple)
    }
}
extension Models.MFACodeResponse {
    public init(code: String, mfaContext: Models.MFACodeContext) {
        self.init(mfaRequired: .code, code: code, mfaContext: mfaContext)
    }
}
extension Models.MFALinkResponse {
    public init(link: String, mfaContext: Models.MFALinkContext) {
        self.init(mfaRequired: .link, link: link, mfaContext: mfaContext)
    }
}
extension Models.ActiveLinkedAccountDetails {
    public init(accountOpened: String, username: String, emailAddress: String, legalName: String) {
        self.init(
            state: .active,
            accountOpened: accountOpened,
            username: username,
            emailAddress: emailAddress,
            legalName: legalName)
    }
}
extension Models.InactiveLinkedAccountDetails {
    public init() {
        self.init(state: .inactive)
    }
}
