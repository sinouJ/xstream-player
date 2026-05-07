import Foundation

extension APIClient {
    func fetchItems(userId: String, parentId: String? = nil) async throws -> [MediaItem] {
        var path = "Items?Recursive=true&IncludeItemTypes=Movie,Series,Episode&Fields=Genres,Overview"
        if let parentId { path += "&ParentId=\(parentId)" }
        let response: JellyfinItemsResponse = try await request(path)
        return response.items.map(MediaItem.init)
    }

    func fetchImageItem(imageType: ImageType, itemId: String) async throws -> Data {
        try await rawRequest("Items/\(itemId)/Images/\(imageType.rawValue)")
    }

    func fetchLastFilmItems(userId: String, limit: Int = 5) async throws -> [MediaItem] {
        let path = "Items"
            + "?Recursive=true"
            + "&IncludeItemTypes=Movie"
            + "&Fields=Genres,Overview,MediaStreams"
            + "&SortBy=DateCreated"
            + "&SortOrder=Descending"
            + "&Limit=\(limit)"
        let response: JellyfinItemsResponse = try await request(path)
        return response.items.map(MediaItem.init)
    }
    
    func fetchLastSeriesItems(userId: String, limit: Int = 5) async throws -> [MediaItem] {
        let path = "Items"
            + "?Recursive=true"
            + "&IncludeItemTypes=Series"
            + "&Fields=Genres,Overview,MediaStreams"
            + "&SortBy=DateCreated"
            + "&SortOrder=Descending"
            + "&Limit=\(limit)"
            let response: JellyfinItemsResponse = try await request(path)
            return response.items.map(MediaItem.init)
    }

    func fetchResumableItems(userId: String) async throws -> [MediaItem] {
        let path = "UserItems/Resume"
            + "?Recursive=true"
            + "&IncludeItemTypes=Movie,Episode"
            + "&Fields=UserData,RunTimeTicks,Genres,Overview"
            + "&SortBy=DatePlayed"
            + "&SortOrder=Descending"
            + "&Limit=20"
        let response: JellyfinItemsResponse = try await request(path)
        return response.items.map(MediaItem.init)
    }
}
