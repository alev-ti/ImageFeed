import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private var photos: [Photo] = []
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let imageService: ImagesListService = .shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        fetchPhotos()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let photo = photos[indexPath.row]
            viewController.imageURL = URL(string: photo.largeImageURL)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == showSingleImageSegueIdentifier {
//            guard
//                let viewController = segue.destination as? SingleImageViewController,
//                let indexPath = sender as? IndexPath
//            else {
//                assertionFailure("Invalid segue destination")
//                return
//            }
//
//            let photo = photos[indexPath.row]
//            if let image = UIImage(named: photo.largeImageURL) {
//                viewController.image = image
//            }
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
    
    private func fetchPhotos() {
        guard let token = oauth2TokenStorage.token else { return }
        
        imageService.fetchPhotosNextPage(token) { result in
            switch result {
            case .success(let photos):
                self.photos.append(contentsOf: photos)
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func fetchPhotosNextPage() {
        guard let token = oauth2TokenStorage.token else { return }
        
        imageService.fetchPhotosNextPage(token) { result in
            switch result {
            case .success(let newPhotos):
                self.photos.append(contentsOf: newPhotos)
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private func calculateCellHeight(for imageSize: CGSize) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageSize.width
        return imageSize.height * scale + imageInsets.top + imageInsets.bottom
    }
    
    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newPhotos = imageService.photos
        
        guard newPhotos.count > oldCount else {
            return
        }
        
        photos = newPhotos
        
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newPhotos.count).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
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
            fetchPhotosNextPage()
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
                
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        cell.configure(with: photo)
        
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "stub"),
            options: [.transition(.fade(0.2))]
        )
        
        cell.dateLabel.text = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        
        let likeImage = photo.isLiked ? UIImage(named: "like_btn") : UIImage(named: "like_btn_no")
        cell.likeButton.setImage(likeImage, for: .normal)
        
        cell.cellImage.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        let cellHeight = calculateCellHeight(for: photo.size)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0).cgColor,    // #1A1B2200
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.2).cgColor   // #1A1B2233
        ]
        gradientLayer.locations = [0.0, 0.2]  // 0% to 20%
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        
        gradientLayer.frame = CGRect(
            x: 0,
            y: cellHeight - 38,
            width: cell.cellImage.bounds.width,
            height: 30
        )
        
        cell.cellImage.layer.addSublayer(gradientLayer)
    }
}

