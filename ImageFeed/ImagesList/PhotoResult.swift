import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    struct UrlsResult: Decodable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
    
    func toPhoto() -> Photo {
        return Photo(
            id: id,
            size: CGSize(width: width, height: height),
            createdAt: createdAt,
            welcomeDescription: description,
            thumbImageURL: urls.thumb,
            largeImageURL: urls.full,
            isLiked: likedByUser
        )
    }
}

