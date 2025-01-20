import CandleSession
import Foundation
import HTTPTypes
import OpenAPIRuntime

struct AuthorizationMiddleware: ClientMiddleware {
    let authorizationToken: String

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var modifiedRequest = request

        modifiedRequest.headerFields.append(
            HTTPField(
                name: .authorization,
                value: CandleSession.Constants.API.authorizationHeaderValuePrefix
                    + authorizationToken))

        return try await next(modifiedRequest, body, baseURL)
    }
}

struct HeaderEncodingMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var modifiedRequest = request

        modifiedRequest.headerFields = HTTPFields(
            request.headerFields.map { field in
                let modifiedFieldValue: String
                if let _modifiedFieldValue = field.value.removingPercentEncoding {
                    modifiedFieldValue = _modifiedFieldValue
                } else {
                    modifiedFieldValue = field.value
                    // FIXME: Log to analytics here
                }
                return HTTPField(name: field.name, value: modifiedFieldValue)

            })

        return try await next(modifiedRequest, body, baseURL)
    }
}
