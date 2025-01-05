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
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(
            with: url,
            options: []
        ) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let value):
                self.imageView.image = value.image
                self.rescaleAndCenterImageInScrollView(image: value.image)
                case .failure(_):
                showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так. Попробовать ещё раз?",
            message: "",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Не надо", style: .default))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { _ in
            if let imageURL = self.imageURL {
                self.loadImage(from: imageURL)
            }
        })
        present(alert, animated: true)
    }
    
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
