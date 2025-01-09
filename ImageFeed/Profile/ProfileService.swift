import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private var currentTask: URLSessionTask?
    private(set) var profile: Profile?
    
    private init() {}

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {

        currentTask?.cancel()
        
        let completionOnTheMainThread: (Result<Profile, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        guard let url = URL(string: Constants.profileMeUrlString) else {
            let error = URLError(.badURL)
            print("[ProfileService/fetchProfile]: urlRequestError - failed to create URL")
            completionOnTheMainThread(.failure(error))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            self?.currentTask = nil

            switch result {
            case .success(let responseBody):
                let profile = responseBody.toProfile()
                self?.profile = profile
                completionOnTheMainThread(.success(profile))
            case .failure(let error):
                print("[ProfileService/fetchProfile]: NetworkError - \(error.localizedDescription)")
                completionOnTheMainThread(.failure(error))
            }
        }

        currentTask = task
        task.resume()
    }
    
    func clearProfileData() {
        profile = nil
    }
}
