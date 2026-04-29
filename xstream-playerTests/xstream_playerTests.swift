//
//  xstream_playerTests.swift
//  xstream-playerTests
//
//  Created by Jordan Sinou on 25/04/2026.
//

import Testing
import Foundation
@testable import xstream_player_ios

// MARK: - KeychainStore

@Suite("KeychainStore")
struct KeychainStoreTests {
    let store = KeychainStore(service: "xstream-player-unit-tests")

    @Test func saveAndLoad() throws {
        defer { try? store.delete(forKey: "kc_save") }
        try store.save("hello", forKey: "kc_save")
        let result = try store.load(String.self, forKey: "kc_save")
        #expect(result == "hello")
    }

    @Test func overwriteExistingKey() throws {
        defer { try? store.delete(forKey: "kc_overwrite") }
        try store.save("first", forKey: "kc_overwrite")
        try store.save("second", forKey: "kc_overwrite")
        let result = try store.load(String.self, forKey: "kc_overwrite")
        #expect(result == "second")
    }

    @Test func deleteRemovesItem() throws {
        try store.save("temp", forKey: "kc_delete")
        try store.delete(forKey: "kc_delete")
        #expect(throws: KeychainError.self) {
            try store.load(String.self, forKey: "kc_delete")
        }
    }

    @Test func deleteMissingKeySucceeds() throws {
        try store.delete(forKey: "kc_nonexistent_\(UUID().uuidString)")
    }

    @Test func existsTrueAfterSave() throws {
        defer { try? store.delete(forKey: "kc_exists") }
        try store.save(42, forKey: "kc_exists")
        #expect(store.exists(forKey: "kc_exists"))
    }

    @Test func existsFalseWhenAbsent() {
        #expect(!store.exists(forKey: "kc_absent_\(UUID().uuidString)"))
    }
}

// MARK: - AuthCredentials

@Suite("AuthCredentials")
struct AuthCredentialsTests {
    @Test func codableRoundTrip() throws {
        let original = AuthCredentials(
            jellyfinBaseUrl: URL(string: "https://jellyfin.example.com/jellyfin/")!,
            accessToken: "tok_abc123",
            userId: "uid-456",
            username: "john.doe"
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AuthCredentials.self, from: data)
        #expect(decoded.jellyfinBaseUrl == original.jellyfinBaseUrl)
        #expect(decoded.accessToken == original.accessToken)
        #expect(decoded.userId == original.userId)
        #expect(decoded.username == original.username)
    }

    @Test func keychainRoundTrip() throws {
        let store = KeychainStore(service: "xstream-player-unit-tests")
        let key = "credentials_test_\(UUID().uuidString)"
        defer { try? store.delete(forKey: key) }

        let credentials = AuthCredentials(
            jellyfinBaseUrl: URL(string: "https://jellyfin.local/")!,
            accessToken: "token-xyz",
            userId: "user-001",
            username: "alice"
        )
        try store.save(credentials, forKey: key)
        let loaded = try store.load(AuthCredentials.self, forKey: key)
        #expect(loaded.accessToken == credentials.accessToken)
        #expect(loaded.username == credentials.username)
    }
}

// MARK: - JellyfinItem

@Suite("JellyfinItem")
struct JellyfinItemTests {
    @Test func decodesAllFields() throws {
        let json = #"""
        {
            "Id": "item-001",
            "Name": "Inception",
            "Type": "Movie",
            "ProductionYear": 2010,
            "Genres": ["Action", "Sci-Fi"]
        }
        """#.data(using: .utf8)!
        let item = try JSONDecoder().decode(JellyfinItem.self, from: json)
        #expect(item.id == "item-001")
        #expect(item.name == "Inception")
        #expect(item.type == "Movie")
        #expect(item.productionYear == 2010)
        #expect(item.genres == ["Action", "Sci-Fi"])
    }

    @Test func decodesWithMissingOptionals() throws {
        let json = #"{"Id":"x","Name":"Y","Type":"Series"}"#.data(using: .utf8)!
        let item = try JSONDecoder().decode(JellyfinItem.self, from: json)
        #expect(item.productionYear == nil)
        #expect(item.genres == nil)
    }

    @Test func rejectsMissingRequiredFields() {
        let json = #"{"Id":"x","Name":"Y"}"#.data(using: .utf8)!
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(JellyfinItem.self, from: json)
        }
    }
}

// MARK: - JellyfinItemsResponse

@Suite("JellyfinItemsResponse")
struct JellyfinItemsResponseTests {
    @Test func decodesItemsArray() throws {
        let json = #"""
        {"Items":[{"Id":"a","Name":"A","Type":"Movie"},{"Id":"b","Name":"B","Type":"Series"}]}
        """#.data(using: .utf8)!
        let response = try JSONDecoder().decode(JellyfinItemsResponse.self, from: json)
        #expect(response.items.count == 2)
        #expect(response.items[0].id == "a")
        #expect(response.items[1].id == "b")
    }

    @Test func decodesEmptyArray() throws {
        let json = #"{"Items":[]}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(JellyfinItemsResponse.self, from: json)
        #expect(response.items.isEmpty)
    }
}

// MARK: - MediaItem

@Suite("MediaItem")
struct MediaItemTests {
    private func decode(_ dict: [String: Any]) throws -> JellyfinItem {
        let data = try JSONSerialization.data(withJSONObject: dict)
        return try JSONDecoder().decode(JellyfinItem.self, from: data)
    }

    @Test func mapsAllFields() throws {
        let source = try decode([
            "Id": "m1", "Name": "The Dark Knight",
            "Type": "Movie", "ProductionYear": 2008,
            "Genres": ["Action", "Crime"]
        ])
        let item = MediaItem(from: source)
        #expect(item.id == "m1")
        #expect(item.title == "The Dark Knight")
        #expect(item.type == "Movie")
        #expect(item.year == 2008)
        #expect(item.genres == ["Action", "Crime"])
    }

    @Test func mapsNilOptionals() throws {
        let source = try decode(["Id": "x", "Name": "Y", "Type": "Z"])
        let item = MediaItem(from: source)
        #expect(item.year == nil)
        #expect(item.genres == nil)
    }

    @Test func idPreserved() throws {
        let source = try decode(["Id": "unique-id-99", "Name": "N", "Type": "T"])
        let item = MediaItem(from: source)
        #expect(item.id == "unique-id-99")
    }
}

// MARK: - JellyfinUser

@Suite("JellyfinUser")
struct JellyfinUserTests {
    @Test func decodesNameAsUsername() throws {
        let json = #"{"Id":"user-123","Name":"john.doe"}"#.data(using: .utf8)!
        let user = try JSONDecoder().decode(JellyfinUser.self, from: json)
        #expect(user.id == "user-123")
        #expect(user.username == "john.doe")
    }

    // Regression guard: Jellyfin returns "Name", not "Username"
    @Test func usesNameKey() throws {
        let jsonWithName = #"{"Id":"u1","Name":"alice","Username":"bob"}"#.data(using: .utf8)!
        let user = try JSONDecoder().decode(JellyfinUser.self, from: jsonWithName)
        #expect(user.username == "alice")
    }
}

// MARK: - AppError

@Suite("AppError")
struct AppErrorTests {
    @Test func simpleCasesEqual() {
        #expect(AppError.serverUnreachable == .serverUnreachable)
        #expect(AppError.unauthorized == .unauthorized)
        #expect(AppError.timeout == .timeout)
    }

    @Test func genericCaseEquality() {
        #expect(AppError.generic("oops") == .generic("oops"))
        #expect(AppError.generic("a") != .generic("b"))
    }

    @Test func differentCasesNotEqual() {
        #expect(AppError.serverUnreachable != .unauthorized)
        #expect(AppError.timeout != .serverUnreachable)
        #expect(AppError.generic("x") != .serverUnreachable)
    }
}

// MARK: - AppPhase

@Suite("AppPhase")
struct AppPhaseTests {
    @Test func simpleCasesEqual() {
        #expect(AppPhase.launching == .launching)
        #expect(AppPhase.needsAuth == .needsAuth)
        #expect(AppPhase.ready == .ready)
    }

    @Test func errorCaseEquality() {
        #expect(AppPhase.error(.serverUnreachable) == .error(.serverUnreachable))
        #expect(AppPhase.error(.unauthorized) != .error(.serverUnreachable))
    }

    @Test func differentCasesNotEqual() {
        #expect(AppPhase.launching != .ready)
        #expect(AppPhase.needsAuth != .launching)
        #expect(AppPhase.error(.timeout) != .ready)
    }
}

// MARK: - AppState

@Suite("AppState")
struct AppStateTests {
    @Test @MainActor func initialPhaseIsLaunching() {
        let state = AppState()
        #expect(state.phase == .launching)
    }

    @Test @MainActor func didAuthenticateSetsReady() {
        let state = AppState()
        state.didAuthenticate()
        #expect(state.phase == .ready)
    }

    @Test @MainActor func logoutSetsNeedsAuth() {
        let state = AppState()
        state.didAuthenticate()
        state.logout()
        #expect(state.phase == .needsAuth)
    }

    @Test @MainActor func logoutFromErrorSetsNeedsAuth() {
        let state = AppState()
        state.phase = .error(.unauthorized)
        state.logout()
        #expect(state.phase == .needsAuth)
    }

    @Test @MainActor func retryResetsToLaunching() {
        let state = AppState()
        state.phase = .error(.serverUnreachable)
        state.retry()
        // retry() synchronously sets .launching before spawning the bootstrap task
        #expect(state.phase == .launching)
    }
}
