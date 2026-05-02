import SwiftUI

@Observable
final class MediaLibrary {
    var items: [MediaItem] = []
    var resumables: [MediaItem] = []
    var lastFilms: [MediaItem] = []
    var isLoading: Bool = false
    var error: APIError? = nil
    private var lastLoadedAt: Date?
    private let cacheDuration: TimeInterval = 1200

    func loadItems(userId: String) async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        do {
            items = try await APIClient.shared.fetchItems(userId: userId)
        } catch let e as APIError {
            error = e
        } catch {
            print("loadItems error: \(error)")
        }
    }

    func loadResumableItems(userId: String) async {
        do {
            resumables = try await APIClient.shared.fetchResumableItems(userId: userId)
        } catch let e as APIError {
            error = e
        } catch {
            print("loadResumableItems error: \(error)")
        }
    }
    
    func loadLastFilmItems(userId: String) async {
        do {
            lastFilms = try await APIClient.shared.fetchLastFilmItems(userId: userId)
        } catch let e as APIError {
            error = e
        } catch {
            print("loadLastFilmItems error: \(error)")
        }
    }

    func loadImageForLastFilm(itemId: String) async {
        guard let index = lastFilms.firstIndex(where: { $0.id == itemId }) else { return }
        let imageId = lastFilms[index].parentThumbItemId ?? itemId
        do {
            lastFilms[index].primary = try await APIClient.shared.fetchImageItem(imageType: .primary, itemId: imageId)
        } catch {
            print("loadImageForLastFilm error: \(error)")
        }
    }

    func loadImageItem(itemId: String) async {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        let imageId = items[index].parentThumbItemId ?? itemId
        do {
            items[index].thumbnail = try await APIClient.shared.fetchImageItem(imageType: .thumbnail, itemId: imageId)
        } catch {
            print("loadImageItem error: \(error)")
        }
    }

    func loadImageForResumable(itemId: String) async {
        guard let index = resumables.firstIndex(where: { $0.id == itemId }) else { return }
        let imageId = resumables[index].parentThumbItemId ?? itemId
        do {
            resumables[index].primary = try await APIClient.shared.fetchImageItem(imageType: .primary, itemId: imageId)
        } catch {
            print("loadImageForResumable error: \(error)")
        }
    }
    
    func loadImageForMediaDetailView(itemId: String) async {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        let imageId = items[index].parentThumbItemId ?? itemId
        do {
            items[index].banner = try await APIClient.shared.fetchImageItem(imageType: .thumbnail, itemId: imageId)
        } catch {
            print("loadImageForMediaDetailView error: \(error)")
        }
    }
    
    func loadIfNeeded(userId: String) async {
        if let lastLoadedAt,
           Date().timeIntervalSince(lastLoadedAt) < cacheDuration,
           !items.isEmpty {
            return
        }
        
        async let items = loadItems(userId: userId)
        async let resumables = loadResumableItems(userId: userId)
        async let lastFilms = loadLastFilmItems(userId: userId)
        
        _ = await (items, resumables, lastFilms)
        lastLoadedAt = Date()
    }
    
    func refresh(userId: String) async {
        lastLoadedAt = nil
        await loadIfNeeded(userId: userId)
    }
}
