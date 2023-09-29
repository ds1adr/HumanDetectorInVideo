//
//  ImageViewController.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/24/23.
//

import UIKit

class ImageViewController: UIViewController {

    static func makeImageViewController() -> ImageViewController {
        let viewController = ImageViewController(nibName: "ImageViewController", bundle: nil)
        return viewController
    }

    @IBOutlet var imageView: UIImageView!
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let image else { return }
        imageView.image = image
    }


}
