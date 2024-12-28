import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    
    var imageURL: URL? {
        didSet {
            guard isViewLoaded, let imageURL else { return }
            loadImage(from: imageURL)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
        
        if let imageURL = imageURL {
            loadImage(from: imageURL)
        }
    }
    
    private func loadImage(from url: URL) {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: url,
//            placeholder: UIImage(named: "stub"),
            options: []
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.imageView.image = value.image
                self.rescaleAndCenterImageInScrollView(image: value.image)
            case .failure(let error):
                print("Failed to load image: \(error)")
            }
        }
    }
    
//    private func loadImage(from url: URL) {
//        // Создаем кастомный placeholder
//        let placeholderView = UIView()
//        placeholderView.backgroundColor = .ypBlack
//        
//        let label = UILabel()
//        label.text = "Загрузка..."
//        label.textColor = .white
//        label.translatesAutoresizingMaskIntoConstraints = false
//        placeholderView.addSubview(label)
//        
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor)
//        ])
//        
//        // Добавляем placeholderView в imageView
//        imageView.addSubview(placeholderView)
//        placeholderView.frame = imageView.bounds
//        
//        // Включаем индикатор загрузки
//        imageView.kf.indicatorType = .activity
//        
//        // Загружаем изображение
//        imageView.kf.setImage(
//            with: url,
//            placeholder: nil, // Не используем изображение как placeholder
//            options: [.transition(.fade(0.2))]
//        ) { [weak self] result in
//            guard let self = self else { return }
//            
//            // Убираем кастомный placeholder после загрузки
//            placeholderView.removeFromSuperview()
//            
//            switch result {
//            case .success(let value):
//                // Устанавливаем загруженное изображение
//                self.imageView.image = value.image
//                self.imageView.backgroundColor = .clear // Убираем фон после загрузки
//                self.rescaleAndCenterImageInScrollView(image: value.image)
//            case .failure(let error):
//                print("Failed to load image: \(error)")
//            }
//        }
//    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()
        
        let scrollViewSize = scrollView.bounds.size
        let imageSize = image.size
        
        let hScale = scrollViewSize.width / imageSize.width
        let vScale = scrollViewSize.height / imageSize.height
        let scale = min(hScale, vScale)
        
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
        
        scrollView.contentSize = imageView.frame.size
        centerImageInScrollView()
    }
    
    private func centerImageInScrollView() {
        let visibleRectSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        let xOffset = max(0, (visibleRectSize.width - contentSize.width) / 2)
        let yOffset = max(0, (visibleRectSize.height - contentSize.height) / 2)
        scrollView.contentInset = UIEdgeInsets(top: yOffset, left: xOffset, bottom: yOffset, right: xOffset)
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else {
            print("No image found")
            return
        }
        let text = "Shared with love from ImageFeed App"
        let vc = UIActivityViewController(
            activityItems: [image, text],
            applicationActivities: []
        )
        present(vc, animated: true, completion: nil)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageInScrollView()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
