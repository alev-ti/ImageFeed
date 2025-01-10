import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidResponse
    case unAuthorized
    case invalidURL
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    let error = NetworkError.httpStatusCode(statusCode)
                    print("[data(for:)]: NetworkError - error code \(statusCode), URL: \(request.url?.absoluteString ?? "unknown URL")")
                    fulfillCompletionOnTheMainThread(.failure(error))
                }
            } else if let error = error {
                print("[data(for:)]: urlRequestError - \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "unknown URL")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("[data(for:)]: urlSessionError, URL: \(request.url?.absoluteString ?? "unknown URL")")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })

        return task
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(decodedObject))
                    }
                } catch {
                    let dataString = String(data: data, encoding: .utf8) ?? ""
                    print("[objectTask]: Decoding error - \(error.localizedDescription), Data: \(dataString)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print("[objectTask]: NetworkError - \(error.localizedDescription), URL: \(request.url?.absoluteString ?? "unknown URL")")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        return task
    }
}

