import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}

    private let tokenStorage = OAuth2TokenStorage()

    func fetchOAuthToken(
        _ code: String, completion: @escaping (Result<String, Error>) -> Void
    ) {
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
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) {
            [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let error = URLError(.badServerResponse)
                print("Invalid server response")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let error = URLError(.badServerResponse)
                print("Server error: status code \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                let error = URLError(.badServerResponse)
                print("No data received from server")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let responseBody = try decoder.decode(
                    OAuthTokenResponseBody.self, from: data)
                self?.tokenStorage.token = responseBody.accessToken
                DispatchQueue.main.async {
                    completion(.success(responseBody.accessToken))
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
