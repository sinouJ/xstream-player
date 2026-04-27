//
//  APIClient.swift
//  xstream-player
//
//  Created by Jordan Sinou on 25/04/2026.
//

import Foundation
import UIKit

enum APIError: Error {
    case invalidURL
    case unauthorized
    case decodingError
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
    
    private let jellyfinBaseURL = "https://jellyfin.xstream.ink/jellyfin" // TODO: Use URL type
    private let apiKey: String = "af0ff7d097624d998e97023ce3a80c10"
    
    private var defaultHeaders: [String: String] {
        [
            "X-Emby-Token": apiKey,
            "Content-Type": "application/json",
            "X-Emby-Client": "xstream-player",
            "X-Emby-Device-Name": deviceName,
            "X-Emby-Device-Id": UUID().uuidString,
            "X-Emby-Client-Version": "1.0.0"
        ]
    }
    
    private func request<T: Decodable>(_ path: String) async throws -> T {
        guard let url = URL(string: jellyfinBaseURL + path) else {
            throw APIError.invalidURL
        }

        var req = URLRequest(url: url)
        defaultHeaders.forEach { req.setValue($1, forHTTPHeaderField: $0) }

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.serverError(0)
        }

        switch http.statusCode {
            case 200...299: break
            case 401: throw APIError.unauthorized
            default: throw APIError.serverError(http.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func fetchItems(userId: String, parentId: String? = nil) async throws -> [MediaItem] {
        var path = "/Users/\(userId)/Items?Recursive=true&IncludeItemTypes=Movie,Series,Episode"
        if let parentId { path += "&ParentId=\(parentId)" }
        
        let response: JellyfinItemsResponse = try await request(path)
        return response.items.map(MediaItem.init)
    }
    
    func validateToken() async throws {
        let _: JellyfinUser = try await request("/Users/Me")
    }
    
}
