//
//  JellyfinServer.swift
//  xstream-player
//
//  Created by Jordan Sinou on 28/04/2026.
//
import Foundation

struct AuthCredentials : Codable, Sendable {
    let jellyfinBaseUrl: URL
    let accessToken: String
    let userId: String
    let username: String
}
