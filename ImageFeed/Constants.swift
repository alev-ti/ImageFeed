import Foundation

enum Constants {
    static let accessKey = "1-_4ardYp4i1fbZECvCw_GxKyD4QlL85Qd0n9tmPmZ4"
    static let secretKey = "KAd6KGZ1FZxPi_Br5srGRUmKfjB5cS82N8NCut3L-d4"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashTokenURLString = "https://unsplash.com/oauth/token"
    static let profileMeUrlString = "\(defaultBaseURL)/me"
    static let profileUsersUrlString = "\(defaultBaseURL)/users/"
    static let oauthAuthorizeUrl = "/oauth/authorize/native"
    static let photosUrlString = "\(defaultBaseURL)/photos"
    
    static func getLikedPhotosIdUrlString(photoId: String) -> String {
        "\(defaultBaseURL)/photos/\(photoId)/like"
    }
}

