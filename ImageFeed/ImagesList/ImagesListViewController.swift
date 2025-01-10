import UIKit

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private var photos: [Photo] = []
    private var previousPhotosCount = 0
    
    private let oauth2TokenStorage: OAuth2TokenStorage = .shared
    private let imageService: ImagesListService = .shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main) { [weak self] _ in
                    guard let self = self else { return }
                    self.updateTableViewAnimated()
                }
        previousPhotosCount = 0
        fetchPhotos()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("[ImagesListViewController/prepare]: Invalid segue destination")
                return
            }

            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: ImagesListService.didChangeNotification, object: nil)
    }
    
    private func fetchPhotos() {
        guard let token = oauth2TokenStorage.token else { return }
        
        imageService.fetchPhotosNextPage(token ) { result in
            if case .failure(let error) = result {
                print("[ImagesListViewController/fetchPhotos]: Error fetching photos: \(error)")
            }
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    private func calculateCellHeight(for imageSize: CGSize) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageSize.width
        return imageSize.height * scale + imageInsets.top + imageInsets.bottom
    }
    
    @objc private func updateTableViewAnimated() {
        let newPhotos = imageService.photos

        guard newPhotos.count > previousPhotosCount else {
            return
        }

        let indexPaths = (previousPhotosCount..<newPhotos.count).map {
            IndexPath(row: $0, section: 0)
        }
        
        photos = newPhotos
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
        
        previousPhotosCount = newPhotos.count
    }
    
    private func configureCell(_ cell: ImagesListCell, for indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        cell.delegate = self
        cell.configure(with: photo, dateFormatter: dateFormatter)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageSize = photo.size
        return calculateCellHeight(for: imageSize)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            fetchPhotos()
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
        configureCell(imageListCell, for: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        cell.configure(with: photo, dateFormatter: dateFormatter)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        let isLike = !photo.isLiked
        
        UIBlockingProgressHUD.show()
        imageService.changeLike(photoId: photo.id, isLike: isLike) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success():
                self?.photos[indexPath.row].isLiked = isLike
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            case .failure(let error):
                print("[ImagesListViewController/imageListCellDidTapLike]: Error changing like status: \(error)")
            }
        }
    }
}

