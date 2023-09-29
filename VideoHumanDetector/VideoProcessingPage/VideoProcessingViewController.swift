//
//  VideoProcessingViewController.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/20/23.
//

import UIKit

protocol VideoProcessingPageViewable: AnyObject {
    func setInitialData(duration: TimeInterval)
    func startRunning()
    func updateImage(mainImage: UIImage, maskImage: UIImage, finalImage: UIImage)
    func updateProgress(time: TimeInterval, progress: Float)
    func processComplete(error: Error?)
}

class VideoProcessingViewController: UIViewController, VideoProcessingPageViewable {
    static func makeVideoProcessingViewController(presenter: VideoProcessingPagePresenting) -> VideoProcessingViewController {
        let viewController = VideoProcessingViewController(nibName: "VideoProcessingViewController", bundle: nil)
        viewController.presenter = presenter
        return viewController
    }

    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var maskImageView: UIImageView!
    @IBOutlet var finalImageView: UIImageView!

    var presenter: VideoProcessingPagePresenting?
    private var isProcessRunning = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonClicked))
        self.navigationItem.leftBarButtonItem = backButton
        
        presenter?.viewable = self
        presenter?.viewLoaded()
    }

    func startRunning() {
        isProcessRunning = true
    }

    @objc
    func backButtonClicked() {
        if isProcessRunning {
            displayAlert(title: nil, message: "Process is running now, please wait")
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    func setInitialData(duration: TimeInterval) {
        currentTimeLabel.text = "0"
        durationLabel.text = String(format: "%.1f", duration)
        progressView.progress = 0
    }

    @MainActor
    func updateImage(mainImage: UIImage, maskImage: UIImage, finalImage: UIImage) {
        mainImageView.image = mainImage
        maskImageView.image = maskImage
        finalImageView.image = finalImage
    }

    @MainActor
    func updateProgress(time: TimeInterval, progress: Float) {
        currentTimeLabel.text = String(format: "%.1f", time)
        progressView.progress = progress
    }

    func processComplete(error: Error?) {
        isProcessRunning = false
        if let error {
            displayAlert(title: "Error", message: error.localizedDescription)
        } else {
            displayAlert(title: "Completed", message: "Process completed.")
        }
    }
}

