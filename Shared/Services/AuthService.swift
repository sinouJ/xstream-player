//
//  AuthService.swift
//  xstream-player
//
//  Created by Jordan Sinou on 27/04/2026.
//

import Foundation

final class AuthService {
    static var shared = AuthService()
    
    private init() {}
    
    // TODO: à terme, lire/écrire dans le Keychain
    private var storedToken: String? {
        get { UserDefaults.standard.string(forKey: "jellyfin_token") }
        set { UserDefaults.standard.set(newValue, forKey: "jellyfin_token") }
    }
    
    var hasValidToken: Bool {
        storedToken != nil && !(storedToken?.isEmpty ?? true)
    }
    
    var token: String? {
        storedToken
    }
    
    func saveToken(_ token: String) {
        storedToken = token
    }
    
    func clearToken() {
        storedToken = nil
    }
}
