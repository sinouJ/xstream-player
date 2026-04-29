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
        } catch let apiError as APIError {
            _ = await minimumDelay
            switch apiError {
            case .unauthorized:
                phase = .error(.unauthorized)
            default:
                phase = .error(.serverUnreachable)
            }
        } catch let urlError as URLError {
            _ = await minimumDelay
            phase = urlError.code == .timedOut ? .error(.timeout) : .error(.serverUnreachable)
        } catch {
            _ = await minimumDelay
            phase = .error(.serverUnreachable)
        }
    }
    
    func didAuthenticate() {
        phase = .ready
    }
    
    func logout() {
        authService.clear()
        phase = .needsAuth
    }
    
    func retry() {
        phase = .launching
        Task { await bootstrap() }
    }
}
