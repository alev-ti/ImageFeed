import Foundation
import SwiftKeychainWrapper

protocol OAuth2TokenStorageProtocol: AnyObject {
    var token: String? { get set }
    func clearToken()
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    static let shared = OAuth2TokenStorage()
    private let tokenKey = "bearerToken"
    
    private init() {}

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    
    func clearToken() {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
    }
}
