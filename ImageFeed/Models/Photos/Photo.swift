import UIKit

public struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let description: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}

extension Photo {
    static var mock: Photo {
        Photo(
            id: UUID().uuidString,
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            description: "Mock",
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            isLiked: false
        )
    }
}
