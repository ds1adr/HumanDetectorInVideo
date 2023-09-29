//
//  HumanDetector.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/20/23.
//

import Foundation
import Photos
import Vision
import UIKit

class HumanDetector: MLDetector {
    let context = CIContext(options: nil)
    let filter = CIFilter(name: "CIBlendWithMask")
    var originalSize: CGSize = .zero

    /**
     For Live Photo and Image
     */
    func processImage(ciImage: CIImage) -> Result<CIImage, Error> {
        let segmentationRequest = VNGeneratePersonSegmentationRequest()
        segmentationRequest.qualityLevel = .balanced

        let humanRectRequest = VNDetectHumanRectanglesRequest()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return .failure(DetectorError.processingError) }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        do {
            try requestHandler.perform([humanRectRequest, segmentationRequest])

            if let humanRectResults = humanRectRequest.results, !humanRectResults.isEmpty {
                if let maskPixelBuffer = segmentationRequest.results?.first?.pixelBuffer {
                    var ciMaskImage = CIImage(cvImageBuffer: maskPixelBuffer)

                    let originalSize = ciImage.extent.size

                    //Convert the maskimage to CIImage and set the size
                    let scaleX = originalSize.width / ciMaskImage.extent.width
                    let scaleY = originalSize.height / ciMaskImage.extent.height

                    ciMaskImage = ciMaskImage.transformed(by: .init(scaleX: scaleX, y: scaleY))

                    let backgroundCIImage = CIImage(color: CIColor(color: .green)).cropped(to: CGRect(x: 0, y: 0, width: originalSize.width, height: originalSize.height))

                    guard let filter  else { return .failure(DetectorError.filterError) }

                    filter.setValue(backgroundCIImage, forKey: kCIInputBackgroundImageKey)
                    filter.setValue(ciImage, forKey: kCIInputImageKey)
                    filter.setValue(ciMaskImage, forKey: kCIInputMaskImageKey)
                    //Update the UI
                    if let ciOutImage = filter.outputImage {
                        let fileURL = KFileManager.makeFilename(type: .image)
                        saveJPEG(url: fileURL, ciImage: ciOutImage)
                        return .success(ciOutImage)
                    }
                }
            }
        } catch {
            return .failure(DetectorError.processingError)
        }
        return .failure(DetectorError.processingError)
    }

    /**
     Save output image in the document directory
     - Parameters
     url: document directory
     ciImage: filter process result image
     */
    @discardableResult func saveJPEG(url: URL, ciImage: CIImage, quality:CGFloat = 1.0) -> Bool {
        if let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) {
            do {
                let context = CIContext()
                try context.writeJPEGRepresentation(of: ciImage, to: url, colorSpace: colorSpace, options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption : quality])
            } catch {
                return false
            }
        }
        return true
    }

    /**
     For video assets
     */
    func processVideo(input: PHContentEditingInput,
                      assetPixelSize: CGSize,
                      progress: @MainActor @escaping (TimeInterval) -> Void,
                      workingImages: @MainActor @escaping (CIImage, CIImage, CIImage) -> Void,
                      completion: @MainActor @escaping (Error?) -> Void) throws {
        guard let inputURL = input.value(forKey: "videoURL") as? URL else { return }
        let asset = AVAsset(url: inputURL)
        guard let reader = try? AVAssetReader(asset: asset) else { return }

        let videoOutputURL = KFileManager.makeFilename(type: .video)

        Task {
            let videoTracks = try await asset.loadTracks(withMediaType: AVMediaType.video)
            let fps = try await videoTracks.first?.load(.nominalFrameRate)

            guard let fps else { return }
            originalSize = assetPixelSize

            let output = AVAssetReaderVideoCompositionOutput(videoTracks: videoTracks, videoSettings: [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)])

            output.videoComposition = AVVideoComposition(propertiesOf: asset)
            reader.add(output)
            reader.startReading()

            let backgroundCIImage = CIImage(color: CIColor(color: .green)).cropped(to: CGRect(x: 0, y: 0, width: originalSize.width, height: originalSize.height))

            let videoWriterPair = makeVideoWriter(url: videoOutputURL)
            let videoWriterInput = videoWriterPair.1
            let pixelBufferAdaptor = videoWriterPair.2

            guard let videoWriter = videoWriterPair.0, videoWriter.startWriting() else { return }

            videoWriter.startSession(atSourceTime: CMTime.zero)

            let media_queue = DispatchQueue(label: "mediaInputQueue")

            videoWriterInput.requestMediaDataWhenReady(on: media_queue, using: { [weak self] () -> Void in
                guard let self else { return }
                let frameDuration = CMTimeMake(value: 1, timescale: Int32(round(fps)))

                var frameCount: Int64 = 0

                while let sampleBuffer = output.copyNextSampleBuffer() {
                    print("sample at time \(CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds)")
                    Task { @MainActor in
                        progress(CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds)
                    }

                    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

                    let originalCIImage = CIImage(cvImageBuffer: imageBuffer)
                    if let originalCGImage = context.createCGImage(originalCIImage, from: originalCIImage.extent) {

                        let segmentationRequest = VNGeneratePersonSegmentationRequest()
                        segmentationRequest.qualityLevel = .balanced

                        let humanRectRequest = VNDetectHumanRectanglesRequest()
                        let requestHandler = VNImageRequestHandler(cgImage: originalCGImage)

                        do {
                            // Perform the body pose-detection request.
                            try requestHandler.perform([humanRectRequest, segmentationRequest])
                            // HumanRect Detect success
                            if let humanRectResults = humanRectRequest.results, !humanRectResults.isEmpty {
                                // Human Segmentation  success
                                if let maskPixelBuffer = segmentationRequest.results?.first?.pixelBuffer {
                                    var ciMaskImage = CIImage(cvImageBuffer: maskPixelBuffer)

                                    let scaleX = originalSize.width / ciMaskImage.extent.width
                                    let scaleY = originalSize.height / ciMaskImage.extent.height

                                    ciMaskImage = ciMaskImage.transformed(by: .init(scaleX: scaleX, y: scaleY))

                                    //Use CIBlendWithMask to combine the three images
                                    guard let filter  else { fatalError("Filter is invalid") }

                                    filter.setValue(backgroundCIImage, forKey: kCIInputBackgroundImageKey)
                                    filter.setValue(originalCIImage, forKey: kCIInputImageKey)
                                    filter.setValue(ciMaskImage, forKey: kCIInputMaskImageKey)

                                    //Update the UI
                                    if let ciOutImage = filter.outputImage,
                                       let cgOutImage = convertCIImageToCGImage(inputImage: ciOutImage) {
                                        let lastFrameTime = CMTimeMake(value: frameCount, timescale: Int32(round(fps)))
                                        let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)

                                        if write(outputCIImage: ciOutImage, cgOutImage: cgOutImage, pixelBufferAdapter: pixelBufferAdaptor, presentationTime: presentationTime) {
                                            frameCount += 1
                                        }

                                        Task { @MainActor [ciMaskImage] in
                                            workingImages(originalCIImage, ciMaskImage, ciOutImage)
                                        }
                                    }
                                }
                            }
                        } catch {
                            print("Unable to perform the request: \(error).")
                        }
                    }

                }

                videoWriterInput.markAsFinished()
                videoWriter.finishWriting { () -> Void in
                    Task { @MainActor in
                        completion(nil)
                    }
                }
            })
        }
    }

    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }

    func write(outputCIImage: CIImage, cgOutImage: CGImage, pixelBufferAdapter: AVAssetWriterInputPixelBufferAdaptor, presentationTime: CMTime) -> Bool {
        var cvPixelBuffer: CVPixelBuffer?
        guard let pixelBufferPool: CVPixelBufferPool = pixelBufferAdapter.pixelBufferPool else {
            print("pixelBufferPool is nil")
            return false
        }
        precondition(CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool, &cvPixelBuffer) == kCVReturnSuccess)

        guard let cvPixelBuffer else { return false }
        CVPixelBufferLockBaseAddress(cvPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

        let data = CVPixelBufferGetBaseAddress(cvPixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: data,
                                      width: Int(originalSize.width),
                                      height: Int(originalSize.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(cvPixelBuffer),
                                      space: rgbColorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) else { return false }

        context.clear(CGRectMake(0, 0, originalSize.width, originalSize.height))

        context.draw(cgOutImage, in: CGRectMake(0, 0, originalSize.width, originalSize.height))

        CVPixelBufferUnlockBaseAddress(cvPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBufferAdapter.append(cvPixelBuffer, withPresentationTime: presentationTime)
    }

    func makeVideoWriter(url: URL) -> (AVAssetWriter?, AVAssetWriterInput, AVAssetWriterInputPixelBufferAdaptor) {
        let avOutputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: NSNumber(value: originalSize.width),
            AVVideoHeightKey: NSNumber(value: originalSize.height)
        ]

        let sourcePixelBufferAttributesDictionary = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: NSNumber(value: originalSize.width),
            kCVPixelBufferHeightKey as String: NSNumber(value: originalSize.height)
        ]

        let videoWriter = try! AVAssetWriter(outputURL: url, fileType: AVFileType.mov)
        let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: avOutputSettings)
        videoWriter.add(videoWriterInput)

        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput,
                                                                  sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)

        return (videoWriter, videoWriterInput, pixelBufferAdaptor)
    }
}
