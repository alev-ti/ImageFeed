import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var photoId: String?
    private var isLiked: Bool = false {
        didSet {
            let likeImage = isLiked ? UIImage(named: "like_btn") : UIImage(named: "like_btn_no")
            likeButton.setImage(likeImage, for: .normal)
        }
    }
    
    @IBAction func onLikeButtonTap(_ sender: Any) {
        guard let photoId = photoId else { return }
        
        ImagesListService.shared.changeLike(photoId: photoId, isLike: !isLiked) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.isLiked.toggle()
            case .failure(let error):
                print("Failed to change like: \(error)")
            }
        }
    }
    
    func configure(with photo: Photo) {
        photoId = photo.id
        isLiked = photo.isLiked
    }
}

