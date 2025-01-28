import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private let presenter: ImagesListPresenterProtocol = ImagesListPresenter()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        presenter.view = self
        setupTableView()
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

            let photo = presenter.photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: ImagesListService.didChangeNotification, object: nil)
    }
    
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
    
    func updateTableViewAnimated() {
        let newPhotos = presenter.photos
        let previousPhotosCount = presenter.getPreviousPhotosCount()

        guard newPhotos.count > previousPhotosCount else {
            print("[ImagesListViewController/updateTableViewAnimated]: No new photos to display")
            return
        }

        let indexPaths = (previousPhotosCount..<newPhotos.count).map {
            IndexPath(row: $0, section: 0)
        }
        
        print("[ImagesListViewController/updateTableViewAnimated]: Inserting \(indexPaths.count) new rows")
        
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
        
        presenter.setPreviousPhotosCount(newPhotos.count)
    }
    
    private func configureCell(_ cell: ImagesListCell, for indexPath: IndexPath) {
        let photo = presenter.photos[indexPath.row]
        cell.delegate = self
        cell.configure(with: photo, dateFormatter: dateFormatter)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = presenter.photos[indexPath.row]
        let imageSize = photo.size
        return calculateCellHeight(for: imageSize)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == presenter.photos.count - 1 {
            presenter.fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
        configureCell(imageListCell, for: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = presenter.photos[indexPath.row]
        let isLike = !photo.isLiked
        
        UIBlockingProgressHUD.show()
        presenter.changeLike(photoId: photo.id, isLike: isLike) { [weak self] success in
            UIBlockingProgressHUD.dismiss()
            if success {
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}
