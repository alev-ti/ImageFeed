import Foundation

typealias OAuthTokenResult = (Result<String, Error>) -> Void

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}

    private let tokenStorage = OAuth2TokenStorage()

    func fetchOAuthToken(
        _ code: String, completion: @escaping OAuthTokenResult
    ) {
        let completionOnTheMainThread: OAuthTokenResult = { result in
            DispatchQueue.main.async {
                completion(result)
            }
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
            completionOnTheMainThread(.failure(error))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error)")
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

                let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                self?.tokenStorage.token = responseBody.accessToken
                completionOnTheMainThread(.success(responseBody.accessToken))
            } catch {
                print("Decoding error: \(error)")
                completionOnTheMainThread(.failure(error))
            }
        }.resume()
    }
}
