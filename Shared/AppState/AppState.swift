//
//  AppState.swift
//  xstream-player
//
//  Created by Jordan Sinou on 27/04/2026.
//
import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    var phase: AppPhase = .launching
    
    private let authService: AuthService
    private let apiClient: APIClient
    
    init(authService: AuthService? = nil, apiClient: APIClient? = nil) {
        self.authService = authService ?? .shared
        self.apiClient = apiClient ?? .shared
    }
    
    func bootstrap() async {
        async let minimumDelay: Void = try! Task.sleep(for: .seconds(1.5))
        
        do {
            guard authService.hasValidToken else {
                _ = await minimumDelay
                phase = .needsAuth
                return
            }
            
            try await apiClient.validateToken()
            
            _ = await minimumDelay
            phase = .ready
        } catch {
            _ = await minimumDelay
            phase = .error(error.localizedDescription)
        }
    }
    
    func didAuthenticate() {
        phase = .ready
    }
    
    func logout() {
        authService.clearToken()
        phase = .needsAuth
    }
    
    func retry() {
        phase = .launching
        Task { await bootstrap() }
    }
}
