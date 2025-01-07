import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var delegate: ImagesListCellDelegate?
    
    private var photoId: String?
    private var setIsLiked: Bool = false {
        didSet {
            let likeImage = setIsLiked ? UIImage(named: "like_btn") : UIImage(named: "like_btn_no")
            likeButton.setImage(likeImage, for: .normal)
        }
    }
    
    @IBAction func onLikeButtonTap(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func configure(with photo: Photo, dateFormatter: DateFormatter) {
        photoId = photo.id
        setIsLiked = photo.isLiked
        
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "stub"),
            options: [.transition(.fade(0.2))]
        )
        
        dateLabel.text = photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        
        cellImage.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0).cgColor,
            UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.2).cgColor
        ]
        gradientLayer.locations = [0.0, 0.2]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.frame = CGRect(
            x: 0,
            y: frame.height - 38,
            width: bounds.width,
            height: 30
        )
        cellImage.layer.addSublayer(gradientLayer)
    }

}

