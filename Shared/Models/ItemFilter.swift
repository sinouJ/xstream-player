import Foundation

enum ItemFilter: String, CaseIterable, Sendable {
    case isFolder          = "IsFolder"
    case isNotFolder       = "IsNotFolder"
    case isUnplayed        = "IsUnplayed"
    case isPlayed          = "IsPlayed"
    case isFavorite        = "IsFavorite"
    case isResumable       = "IsResumable"
    case likes             = "Likes"
    case dislikes          = "Dislikes"
    case isFavoriteOrLikes = "IsFavoriteOrLikes"

    static func queryValue(for filters: [ItemFilter]) -> String {
        filters.map(\.rawValue).joined(separator: ",")
    }
}
