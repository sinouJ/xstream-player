import Foundation

enum AppError: Error, Equatable {
    case serverUnreachable
    case unauthorized
    case timeout
    case generic(String)
}
