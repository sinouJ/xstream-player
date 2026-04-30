import SwiftUI

@Observable
final class MediaFolder {
    var libraries: [MediaItem] = []
    var isLoading: Bool = false
    var error: APIError? = nil
    
    func loadLibraries() async {
        isLoading = true
        error = nil
        
        do {
            libraries = try await APIClient.shared.fetchLibraries()
        } catch let e as APIError {
            error = e
        } catch {
            print("Error: \(error)")
        }
        
        isLoading = false
    }
}
