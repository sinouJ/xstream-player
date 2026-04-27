//
//  AppPhase.swift
//  xstream-player
//
//  Created by Jordan Sinou on 27/04/2026.
//
import Foundation

enum AppPhase: Equatable {
    case launching
    case needsAuth
    case ready
    case error(String)
}
