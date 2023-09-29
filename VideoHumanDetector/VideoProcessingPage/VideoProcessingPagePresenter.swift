//
//  VideoProcessingPagePresenter.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/20/23.
//
import Photos
import UIKit

protocol VideoProcessingPagePresenting {
    var viewable: VideoProcessingPageViewable? { get set }

    func viewLoaded()
}

class VideoProcessingPagePresenter: VideoProcessingPagePresenting {
    private var asset: PHAsset
    private var contentEditingInput: PHContentEditingInput?
    private var detector: MLDetector
    
    weak var viewable: VideoProcessingPageViewable?

    init(asset: PHAsset, detector: MLDetector) {
        self.asset = asset
        self.detector = detector
    }

    func viewLoaded() {
        viewable?.startRunning()
        extractContentEditingInput { [weak self] contentEditingInput in
            guard let self, let contentEditingInput else { return }

            do {
                try detector.processVideo(input: contentEditingInput,
                                          assetPixelSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                                          progress: { [weak self] progress in
                                                guard let self else { return }
                                                viewable?.updateProgress(time: progress, progress: Float(progress / asset.duration) )
                                            },
                                          workingImages: { [weak self] originalImage, filterImage, outputImage in
                                                guard let self else { return }
                                                viewable?.updateImage(mainImage: UIImage(ciImage: originalImage),
                                                                      maskImage: UIImage(ciImage: filterImage),
                                                                      finalImage: UIImage(ciImage: outputImage))

                                            },
                                          completion: { [weak self] error in
                                                guard let self else { return }
                                                self.viewable?.processComplete(error: error)
                })
            } catch {
                viewable?.processComplete(error: error)
            }
        }
        viewable?.setInitialData(duration: asset.duration)
    }

    func extractContentEditingInput(completion: @escaping (PHContentEditingInput?) -> Void) {
        let option = PHContentEditingInputRequestOptions()
        option.isNetworkAccessAllowed = true
        option.canHandleAdjustmentData = { data in
            return true
        }
        option.progressHandler = { progress, stop in
            print("ds1adr: \(progress)")
        }
        asset.requestContentEditingInput(with: option) { contentEditing, info in
            completion(contentEditing)
        }
    }
}
