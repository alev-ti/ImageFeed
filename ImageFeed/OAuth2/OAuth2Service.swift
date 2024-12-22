import Foundation

typealias OAuthTokenResult = (Result<String, Error>) -> Void

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}

    private let tokenStorage = OAuth2TokenStorage()
    
    private var currentTask: URLSessionTask?
    private var currentCode: String?

    func fetchOAuthToken(_ code: String, completion: @escaping OAuthTokenResult) {
        let completionOnTheMainThread: OAuthTokenResult = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        if code == currentCode {
            return
        }

        currentTask?.cancel()
        currentCode = code

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
            print("[OAuth2Service/fetchOAuthToken]: urlRequestError - failed to create URL")
            completionOnTheMainThread(.failure(error))
            currentCode = nil
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            defer {
                self?.currentTask = nil
                self?.currentCode = nil
            }

            switch result {
            case .success(let responseBody):
                self?.tokenStorage.token = responseBody.accessToken
                completionOnTheMainThread(.success(responseBody.accessToken))
            case .failure(let error):
                print("[OAuth2Service/fetchOAuthToken]: NetworkError - \(error.localizedDescription)")
                completionOnTheMainThread(.failure(error))
            }
        }

        currentTask = task
        task.resume()
    }
}
