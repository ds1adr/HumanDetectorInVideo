//
//  ImageProcessingViewController.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/20/23.
//

import UIKit

protocol ImageProcessingPageViewable: UIViewController {
    func updateFilteredImage(image: UIImage)
    func startRunning()
}

class ImageProcessingViewController: UIViewController, ImageProcessingPageViewable {

    static func makeImageProcessingViewController(presenter: ImageProcessingPagePresenting) -> ImageProcessingViewController {
        let viewController = ImageProcessingViewController(nibName: "ImageProcessingViewController", bundle: nil)
        viewController.presenter = presenter
        return viewController
    }

    @IBOutlet var filteredImageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var presenter: ImageProcessingPagePresenting?

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter?.viewable = self
        presenter?.viewLoaded()
    }

    @MainActor
    func startRunning() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    @MainActor
    func updateFilteredImage(image: UIImage) {
        activityIndicator.stopAnimating()
        filteredImageView.image = image
    }
}
