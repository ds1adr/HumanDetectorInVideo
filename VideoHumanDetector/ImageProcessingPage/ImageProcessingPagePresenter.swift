//
//  ImageProcessingPagePresenter.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/20/23.
//

import Foundation
import Photos
import UIKit

protocol ImageProcessingPagePresenting {
    var viewable: ImageProcessingPageViewable? { get set }

    func viewLoaded()
}

class ImageProcessingPagePresenter: ImageProcessingPagePresenting {
    private var asset: PHAsset
    private var contentEditingInput: PHContentEditingInput?
    private var detector: MLDetector
    weak var viewable: ImageProcessingPageViewable?
    
    init(asset: PHAsset, detector: MLDetector) {
        self.asset = asset
        self.detector = detector
    }

    func viewLoaded() {
        processImage()
    }
    /**
     Process with Detector
     */
    func processImage() {
        viewable?.startRunning()
        Task {
            getCIImage(from: asset) { [weak self] ciImage in
                guard let self, let ciImage else { return }
                let result = detector.processImage(ciImage: ciImage)
                switch result {
                case .success(let ciImage):
                    let filteredImage = UIImage(ciImage: ciImage)
                    viewable?.updateFilteredImage(image: filteredImage)
                case .failure(let error):
                    Task { @MainActor in
                        self.viewable?.displayError(error: error)
                    }
                }
            }
        }
    }

    /**
     get CIImage from PHAsset
     - Parameters from : asset (PHAsset)
     - Parameters completion
     */
    func getCIImage(from asset:PHAsset, completion: @escaping (CIImage?) -> Void) {
        //For get exif data
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true //download asset metadata from iCloud if needed
        asset.requestContentEditingInput(with: options) { (contentEditingInput: PHContentEditingInput?, _) -> Void in
            let fullImage = CIImage(contentsOf: contentEditingInput!.fullSizeImageURL!)
            print(fullImage!.properties)
            completion(fullImage)
        }
    }
}
