import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private var currentTask: URLSessionTask?
    private(set) var avatarURL: String?
    private let oauth2TokenStorage = OAuth2TokenStorage()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        
        currentTask?.cancel()
        
        let completionOnTheMainThread: (Result<String, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        guard let url = URL(string: "\(Constants.profileUsersUrlString)\(username)") else {
            let error = URLError(.badURL)
            print("Failed to create URL: \(error)")
            completionOnTheMainThread(.failure(error))
            return
        }
        
        guard let token = oauth2TokenStorage.token else {
            print("Failed to get token")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            self?.currentTask = nil
            
            switch result {
            case .success(let responseBody):
                let avatarURL = responseBody.profileImage.small
                self?.avatarURL = avatarURL
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL]
                )
                
                completionOnTheMainThread(.success(avatarURL))
                
            case .failure(let error):
                print("Error: \(error)")
                completionOnTheMainThread(.failure(error))
            }
        }
        
        currentTask = task
        task.resume()
    }

}

