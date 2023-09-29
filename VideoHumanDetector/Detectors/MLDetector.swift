//
//  MLDetector.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/20/23.
//

import Foundation
import Photos
import UIKit

enum DetectorError: Error {
    case filterError
    case processingError
}

/**
 Abstract protocol of Detector
 */
protocol MLDetector {
    func processImage(ciImage: CIImage) -> Result<CIImage, Error>
    func processVideo(input: PHContentEditingInput,
                      assetPixelSize: CGSize,
                      progress: @MainActor @escaping (TimeInterval) -> Void,
                      workingImages: @MainActor @escaping (CIImage, CIImage, CIImage) -> Void,
                      completion: @MainActor @escaping (Error?) -> Void) throws
}
