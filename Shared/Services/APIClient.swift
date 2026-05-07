//
//  APIClient.swift
//  xstream-player
//
//  Created by Jordan Sinou on 25/04/2026.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

enum APIError: Error {
    case invalidURL
    case unauthorized
    case notAuthenticated
    case decodingError
    case unexpectedContentType
    case serverError(Int)
}

final class APIClient {
    static let shared = APIClient()
    
    private var deviceName: String {
        #if os(iOS)
        return UIDevice.current.name
        #elseif os(macOS)
        return Host.current().localizedName ?? "Mac"
        #else
        return "Apple TV"
        #endif
    }
    
    @MainActor
    private var auth: AuthService { .shared }
    
    @MainActor
    private func defaultHeaders(token: String?) -> [String: String] {
        var authHeader = "MediaBrowser Client=\"xstream-player\", Device=\"\(deviceName)\", DeviceId=\"\(deviceUUID)\", Version=\"1.0.0\""
        if let token, !token.isEmpty {
            authHeader += ", Token=\"\(token)\""
        }

        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": authHeader,
            "X-Emby-Client": "xstream-player",
            "X-Emby-Device-Name": deviceName,
            "X-Emby-Device-Id": deviceUUID,
            "X-Emby-Client-Version": "1.0.0"
        ]

        if let token, !token.isEmpty {
            headers["X-Emby-Token"] = token
        }

        return headers
    }
    
    private var deviceUUID: String {
        let key = "device_uuid"
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }
        let new = UUID().uuidString
        UserDefaults.standard.set(new, forKey: key)
        return new
    }
    
    internal func request<T: Decodable>(
        _ path: String,
        method: String = "GET",
        body: Data? = nil,
        baseURLOverride: URL? = nil,
        tokenOverride: String? = nil
    ) async throws -> T {
        let baseUrl = try resolveBaseURL(override: baseURLOverride)
        let token = resolveToken(override: tokenOverride)
        
        guard let url = URL(string: path, relativeTo: baseUrl) else {
            throw APIError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = method
        if let body { req.httpBody = body }
        
        let headers = await MainActor.run { defaultHeaders(token: token) }
        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.serverError(0)
        }

        switch http.statusCode {
            case 200...299: break
            case 401: throw APIError.unauthorized
            default: throw APIError.serverError(http.statusCode)
        }

        let contentType = http.value(forHTTPHeaderField: "Content-Type") ?? ""
        guard contentType.contains("application/json") else {
            throw APIError.unexpectedContentType
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
    
    internal func rawRequest(
        _ path: String,
        baseURLOverride: URL? = nil,
        tokenOverride: String? = nil
    ) async throws -> Data {
        let baseUrl = try resolveBaseURL(override: baseURLOverride)
        let token = resolveToken(override: tokenOverride)

        guard let url = URL(string: path, relativeTo: baseUrl) else {
            throw APIError.invalidURL
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        let headers = await MainActor.run { defaultHeaders(token: token) }
        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.serverError(0)
        }

        switch http.statusCode {
        case 200...299: return data
        case 401: throw APIError.unauthorized
        default: throw APIError.serverError(http.statusCode)
        }
    }

    @MainActor
    private func resolveBaseURL(override: URL?) throws -> URL {
        if let override { return override.withTrailingSlash }
        guard let url = auth.serverUrl else { throw APIError.notAuthenticated }
        return url.withTrailingSlash
    }
    
    @MainActor
    private func resolveToken(override: String?) -> String? {
        override ?? auth.token
    }
}

private extension URL {
    var withTrailingSlash: URL {
        guard !absoluteString.hasSuffix("/") else { return self }
        return URL(string: absoluteString + "/") ?? self
    }
}

