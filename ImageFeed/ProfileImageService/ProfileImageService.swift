import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private var currentTask: URLSessionDataTask?
    private(set) var avatarURL: String?
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
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

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in

            self?.currentTask = nil

            if let error = error {
                if (error as NSError).code == NSURLErrorCancelled {
                    print("Request was cancelled")
                } else {
                    print("Network error: \(error)")
                }
                completionOnTheMainThread(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let error = URLError(.badServerResponse)
                print("Invalid or failed server response")
                completionOnTheMainThread(.failure(error))
                return
            }

            guard let data = data else {
                let error = URLError(.badServerResponse)
                print("No data received from server")
                completionOnTheMainThread(.failure(error))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let responseBody = try decoder.decode(UserResult.self, from: data)
                let avatarURL = responseBody.profileImage.small
                self?.avatarURL = avatarURL
                completionOnTheMainThread(.success(avatarURL))
            } catch {
                print("Decoding error: \(error)")
                completionOnTheMainThread(.failure(error))
            }
        }

        currentTask = task
        task.resume()
    }
}

