//
//  AuthService.swift
//  xstream-player
//
//  Created by Jordan Sinou on 27/04/2026.
//

import Foundation
import Observation

@Observable
@MainActor
final class AuthService {
    static var shared = AuthService()
    private let keychain = KeychainStore()
    private let credentialsKey = "jellyfin_credential"
    private(set) var credentials: AuthCredentials?
    
    private init() {
        loadFromKeychain()
    }
    
    var hasValidToken: Bool {
        credentials != nil
    }
    
    var token: String? {
        credentials?.accessToken
    }
    
    var serverUrl: URL? {
        credentials?.jellyfinBaseUrl
    }
    
    var userId: String? {
        credentials?.userId
    }

    func save(_ credentials: AuthCredentials) throws {
        try keychain.save(credentials, forKey: credentialsKey)
        self.credentials = credentials
    }
    
    func clear() {
        try? keychain.delete(forKey: credentialsKey)
        credentials = nil
    }
    
    private func loadFromKeychain() {
        credentials = try? keychain.load(AuthCredentials.self, forKey: credentialsKey)
    }
}
