import Foundation

protocol ImagesListServiceProtocol: AnyObject {
    var photos: [Photo] { get }
    func fetchPhotosNextPage(_ token: String, completion: @escaping (Result<[Photo], Error>) -> Void)
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    func clearImagesListData()
}

final class ImagesListService: ImagesListServiceProtocol {
    private init() {}
    static let shared = ImagesListService()

    private var currentTask: URLSessionTask?
    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 1

    func fetchPhotosNextPage(
        _ token: String,
        completion: @escaping (Result<[Photo], Error>) -> Void
    ) {
        currentTask?.cancel()

        let completionOnTheMainThread: (Result<[Photo], Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        var components = URLComponents(string: Constants.photosUrlString)
        components?.queryItems = [
            URLQueryItem(name: "page", value: lastLoadedPage.description)
        ]

        guard let url = components?.url else {
            let error = URLError(.badURL)
            print("[ImagesListService/fetchPhotos]: failed to create URL")
            completionOnTheMainThread(.failure(error))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            currentTask = nil

            switch result {
            case .success(let responseBody):
                let newPhotos = responseBody.map { $0.toPhoto() }
                self.photos.append(contentsOf: newPhotos)
                lastLoadedPage += 1

                print("[ImagesListService/fetchPhotosNextPage]: Added \(newPhotos.count) new photos. Posting notification...")
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )

                completionOnTheMainThread(.success(newPhotos))
            case .failure(let error):
                print("[ImagesListService/fetchPhotos]: NetworkError - \(error.localizedDescription)")
                completionOnTheMainThread(.failure(error))
            }
        }

        currentTask = task
        task.resume()
    }

    func changeLike(
        photoId: String, isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NetworkError.unAuthorized))
            return
        }

        let urlString = Constants.getLikedPhotosIdUrlString(photoId: photoId)
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.invalidResponse))
                }
                return
            }

            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                var updatedPhoto = self.photos[index]
                updatedPhoto.isLiked = isLike
                self.photos[index] = updatedPhoto

                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
            }

            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
        task.resume()
    }
    
    func clearImagesListData() {
        photos = []
    }
}
