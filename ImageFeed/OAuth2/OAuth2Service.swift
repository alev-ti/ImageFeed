import Foundation

typealias OAuthTokenResult = (Result<String, Error>) -> Void

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}

    private let tokenStorage = OAuth2TokenStorage()
    
    private var activeTasks: [String: [OAuthTokenResult]] = [:]
    private var currentTask: URLSessionTask?

    func fetchOAuthToken(
        _ code: String, completion: @escaping OAuthTokenResult
    ) {
        let completionOnTheMainThread: OAuthTokenResult = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        if activeTasks[code] != nil {
            activeTasks[code]?.append(completionOnTheMainThread)
            return
        } else {
            activeTasks[code] = [completionOnTheMainThread]
        }

        var components = URLComponents(string: Constants.unsplashTokenURLString)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let url = components?.url else {
            let error = URLError(.badURL)
            print("Failed to create URL: \(error)")
            completeAll(for: code, with: .failure(error))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        currentTask?.cancel()

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            defer {
                self?.activeTasks.removeValue(forKey: code)
                self?.currentTask = nil
            }

            switch result {
            case .success(let responseBody):
                self?.tokenStorage.token = responseBody.accessToken
                self?.completeAll(for: code, with: .success(responseBody.accessToken))
            case .failure(let error):
                print("Error: \(error)")
                self?.completeAll(for: code, with: .failure(error))
            }
        }

        currentTask = task
        task.resume()
    }


    private func completeAll(for code: String, with result: Result<String, Error>) {
        if let completions = activeTasks[code] {
            for completion in completions {
                completion(result)
            }
        }
        activeTasks.removeValue(forKey: code)
    }
}
