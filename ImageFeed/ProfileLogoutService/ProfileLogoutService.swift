import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()

    private init() {}

    func logout() {
        cleanCookies()
        clearProfileData()
        clearImagesListData()
        clearAvatarURL()
        clearToken()
        navigateToAuthScreen()
    }
    
    func clearProfileData() {
        ProfileService.shared.clearProfileData()
    }
    
    func clearImagesListData() {
        ImagesListService.shared.clearImagesListData()
    }
    
    func clearAvatarURL() {
        ProfileImageService.shared.clearAvatarURL()
    }
    
    func clearToken() {
        OAuth2TokenStorage.shared.clearToken()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes, for: [record],
                    completionHandler: {})
            }
        }
    }
    
    private func navigateToAuthScreen() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("[ProfileLogoutService/navigateToRootScreen]: failed to retrieve app window")
                return
            }
            let authViewController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
            window.rootViewController = authViewController
        }
    }
}
