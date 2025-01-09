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
    
    private func clearProfileData() {
        ProfileService.shared.clearProfileData()
    }
    
    private func clearImagesListData() {
        ImagesListService.shared.clearImagesListData()
    }
    
    private func clearAvatarURL() {
        ProfileImageService.shared.clearAvatarURL()
    }
    
    private func clearToken() {
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
            guard let authViewController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
                assertionFailure("Invalid Configuration: failed to cast AuthViewController")
                return
            }
            window.rootViewController = authViewController
        }
    }
}
