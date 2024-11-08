//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by alevtine on 8.11.24..
//

import UIKit

class SingleImageViewController: UIViewController {
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    
}
