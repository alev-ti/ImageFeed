import Foundation

typealias OAuthTokenResult = (Result<String, Error>) -> Void

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}

    private let tokenStorage = OAuth2TokenStorage()
    
    private var activeTasks: [String: [OAuthTokenResult]] = [:]
    private var currentTask: URLSessionDataTask?

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

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            defer {
                self?.activeTasks.removeValue(forKey: code)
                self?.currentTask = nil
            }

            if let error = error {
                print("Network error: \(error)")
                self?.completeAll(for: code, with: .failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let error = URLError(.badServerResponse)
                print("Invalid or failed server response")
                self?.completeAll(for: code, with: .failure(error))
                return
            }

            guard let data = data else {
                let error = URLError(.badServerResponse)
                print("No data received from server")
                self?.completeAll(for: code, with: .failure(error))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                self?.tokenStorage.token = responseBody.accessToken
                self?.completeAll(for: code, with: .success(responseBody.accessToken))
            } catch {
                print("Decoding error: \(error)")
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
