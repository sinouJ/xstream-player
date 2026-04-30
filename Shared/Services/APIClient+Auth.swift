//
//  AuthResponse.swift
//  xstream-player
//
//  Created by Jordan Sinou on 28/04/2026.
//
import Foundation

extension APIClient {
    
    func authenticate(
        serverUrl: URL,
        username: String,
        password: String
    ) async throws -> AuthCredentials {
        
        let bodyDict = [
            "Username": username,
            "Pw": password
        ]
        let body = try JSONEncoder().encode(bodyDict)
        
        let response: AuthResponse = try await request(
            "Users/AuthenticateByName",
            method: "POST",
            body: body,
            baseURLOverride: serverUrl,
            tokenOverride: nil
        )
        
        return AuthCredentials(
            jellyfinBaseUrl: serverUrl,
            accessToken: response.accessToken,
            userId: response.user.id,
            username: response.user.name
        )
    }
    
    func validateToken() async throws {
        let _: JellyfinUser = try await request("Users/Me")
    }
}

private struct AuthResponse: Decodable {
    let user: AuthUser
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case user = "User"
        case accessToken = "AccessToken"
    }
}

private struct AuthUser: Decodable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
    }
}
