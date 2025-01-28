import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var photos: [Photo] { get }
    var view: ImagesListViewControllerProtocol? { get set }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Bool) -> Void)
    func viewDidLoad()
    func getPreviousPhotosCount() -> Int
    func setPreviousPhotosCount(_ count: Int)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private let imageService: ImagesListServiceProtocol
    private let oauth2TokenStorage: OAuth2TokenStorageProtocol
    private var previousPhotosCount = 0
    
    init(imageService: ImagesListServiceProtocol = ImagesListService.shared,
         oauth2TokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage.shared) {
        self.imageService = imageService
        self.oauth2TokenStorage = oauth2TokenStorage
    }
    
    var photos: [Photo] {
        return imageService.photos
    }
    
    func getPreviousPhotosCount() -> Int {
        return previousPhotosCount
    }
    
    func setPreviousPhotosCount(_ count: Int) {
        previousPhotosCount = count
    }
    
    func viewDidLoad() {
        previousPhotosCount = 0
        fetchPhotosNextPage()

        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                if let view = self.view {
                    print("[ImagesListPresenter/Notification]: View is not nil, calling updateTableViewAnimated...")
                    view.updateTableViewAnimated()
                } else {
                    print("[ImagesListPresenter/Notification]: View is nil!")
                }
            }
    }
    
    func fetchPhotosNextPage() {
        guard let token = oauth2TokenStorage.token else { return }
        
        imageService.fetchPhotosNextPage(token) { [weak self] result in
            guard self != nil else { return }
            if case .failure(let error) = result {
                print("[ImagesListPresenter/fetchPhotosNextPage]: Error fetching photos: \(error)")
            }
        }
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Bool) -> Void) {
        imageService.changeLike(photoId: photoId, isLike: isLike) { result in
            switch result {
            case .success():
                completion(true)
            case .failure(let error):
                print("[ImagesListPresenter/changeLike]: Error changing like status: \(error)")
                completion(false)
            }
        }
    }
}
