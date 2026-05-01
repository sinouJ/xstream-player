import Foundation

struct JellyfinItemsResponse: Decodable {
    let items: [JellyfinItem]
    enum CodingKeys: String, CodingKey {
        case items = "Items"
    }
}

struct JellyfinUserData: Decodable {
    let playedPercentage: Double?
    let playbackPositionTicks: Int?
    enum CodingKeys: String, CodingKey {
        case playedPercentage      = "PlayedPercentage"
        case playbackPositionTicks = "PlaybackPositionTicks"
    }
}

struct JellyfinItem: Decodable {
    let id: String
    let name: String
    let type: String
    let productionYear: Int?
    let genres: [String]?
    let communityRating: Double?
    let seriesName: String?
    let parentThumbItemId: String?
    let runTimeTicks: Int?
    let userData: JellyfinUserData?
    let overview: String?
    let officialRating: String?
    let premiereDate: String?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case id                = "Id"
        case name              = "Name"
        case type              = "Type"
        case productionYear    = "ProductionYear"
        case genres            = "Genres"
        case communityRating   = "CommunityRating"
        case seriesName        = "SeriesName"
        case parentThumbItemId = "ParentThumbItemId"
        case runTimeTicks      = "RunTimeTicks"
        case userData          = "UserData"
        case overview          = "Overview"
        case officialRating    = "OfficialRating"
        case premiereDate      = "PremiereDate"
        case voteCount         = "VoteCount"
    }
}

struct MediaItem: Identifiable {
    let id: String
    let title: String
    let type: String
    let year: Int?
    let genres: [String]?
    let rating: Double?
    var image: Data? = nil
    let seriesName: String?
    let parentThumbItemId: String?
    /// Percentage watched (0–100). Populated only for resumable items.
    let watchedPercentage: Double?
    /// Remaining playback time in minutes. Populated only for resumable items.
    let remainingMinutes: Int?
    /// Total runtime in minutes.
    let runtimeMinutes: Int?
    let overview: String?
    let officialRating: String?
    let premiereDate: Date?
    let voteCount: Int?

    init(from item: JellyfinItem) {
        self.id                 = item.id
        self.title              = item.name
        self.type               = item.type
        self.year               = item.productionYear
        self.genres             = item.genres
        self.rating             = item.communityRating
        self.seriesName         = item.seriesName
        self.parentThumbItemId  = item.parentThumbItemId
        self.watchedPercentage  = item.userData?.playedPercentage
        self.overview           = item.overview
        self.officialRating     = item.officialRating
        self.voteCount          = item.voteCount

        self.runtimeMinutes = item.runTimeTicks.map { Int($0 / 600_000_000) }

        if let total = item.runTimeTicks,
           let pos   = item.userData?.playbackPositionTicks,
           total > pos {
            self.remainingMinutes = max(1, Int((total - pos) / 600_000_000))
        } else {
            self.remainingMinutes = nil
        }

        if let raw = item.premiereDate {
            let f = ISO8601DateFormatter()
            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            self.premiereDate = f.date(from: raw) ?? {
                f.formatOptions = [.withInternetDateTime]
                return f.date(from: raw)
            }()
        } else {
            self.premiereDate = nil
        }
    }
}

enum ImageType: String, Codable {
    case thumbnail = "Thumb"
    case primary   = "Primary"
    case banner    = "Banner"
    case backdrop  = "Backdrop"
}
