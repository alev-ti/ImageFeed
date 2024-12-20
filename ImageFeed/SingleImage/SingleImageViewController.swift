import UIKit

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            rescaleAndCenterImageInScrollView(image: image)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.delegate = self
        guard let image else { return }
        imageView.image = image
        rescaleAndCenterImageInScrollView(image: image)
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
        guard let image else {
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
