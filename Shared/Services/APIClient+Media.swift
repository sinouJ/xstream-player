import Foundation

extension APIClient {
    func fetchItems(userId: String, parentId: String? = nil) async throws -> [MediaItem] {
        var path = "Users/\(userId)/Items?Recursive=true&IncludeItemTypes=Movie,Series,Episode"
        if let parentId { path += "&ParentId=\(parentId)" }
        let response: JellyfinItemsResponse = try await request(path)
        return response.items.map(MediaItem.init)
    }

    func fetchLibraries() async throws -> [MediaItem] {
        let response: JellyfinItemsResponse = try await request("Library/MediaFolders")
        return response.items.map(MediaItem.init)
    }

    func fetchImageItem(imageType: ImageType, itemId: String) async throws -> Data {
        try await rawRequest("Items/\(itemId)/Images/\(imageType.rawValue)")
    }

    func fetchLastFilmItems(userId: String, limit: Int = 5) async throws -> [MediaItem] {
        let path = "Users/\(userId)/Items"
            + "?Recursive=true"
            + "&IncludeItemTypes=Movie"
            + "&SortBy=DateCreated"
            + "&SortOrder=Descending"
            + "&Limit=\(limit)"
        let response: JellyfinItemsResponse = try await request(path)
        return response.items.map(MediaItem.init)
    }

    func fetchResumableItems(userId: String) async throws -> [MediaItem] {
        let filters = ItemFilter.queryValue(for: [.isResumable])
        let path = "UserItems/Resume"
            + "?Recursive=true"
            + "&IncludeItemTypes=Movie,Episode"
            + "&Fields=UserData,RunTimeTicks"
            + "&SortBy=DatePlayed"
            + "&SortOrder=Descending"
            + "&Limit=20"
        let response: JellyfinItemsResponse = try await request(path)
        return response.items.map(MediaItem.init)
    }
}
