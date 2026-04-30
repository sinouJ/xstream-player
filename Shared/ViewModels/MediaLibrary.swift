import SwiftUI

@Observable
final class MediaLibrary {
    var items: [MediaItem] = []
    var resumables: [MediaItem] = []
    var isLoading: Bool = false
    var error: APIError? = nil

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

    func loadImageItem(itemId: String, imageType: ImageType) async {
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        let imageId = items[index].parentThumbItemId ?? itemId
        do {
            items[index].image = try await APIClient.shared.fetchImageItem(imageType: imageType, itemId: imageId)
        } catch {
            print("loadImageItem error: \(error)")
        }
    }

    func loadImageForResumable(itemId: String, imageType: ImageType) async {
        guard let index = resumables.firstIndex(where: { $0.id == itemId }) else { return }
        let imageId = resumables[index].parentThumbItemId ?? itemId
        do {
            resumables[index].image = try await APIClient.shared.fetchImageItem(imageType: imageType, itemId: imageId)
        } catch {
            print("loadImageForResumable error: \(error)")
        }
    }
}
