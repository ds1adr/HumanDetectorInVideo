//
//  AssetCollectionViewCell.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/19/23.
//

import Photos
import UIKit

class AssetCollectionViewCell: UICollectionViewCell {

    enum Constants {
        static let thumbnailSize: CGFloat = 300
    }

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var playImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true

        playImageView.image = UIImage(systemName: "play.fill")
    }

    func configure(asset: PHAsset) {
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: CGSize(width: Constants.thumbnailSize, height: Constants.thumbnailSize),
                                              contentMode: .aspectFill,
                                              options: nil) { [weak self] image, info in
            guard let self else { return }
            imageView.image = image
        }
        playImageView.isHidden = asset.mediaType != .video
    }

    func configure(url: URL) {
        let lastPathComponent = url.lastPathComponent
        if lastPathComponent.lowercased().hasSuffix(KFileManager.FileType.video.extString) {
            imageView.image = generateThumbnail(path: url)
        } else if lastPathComponent.lowercased().hasSuffix(KFileManager.FileType.image.extString) {
            imageView.image = UIImage(contentsOfFile: url.path())
        } else {
            imageView.image = UIImage(systemName: "folder.badge.minus")
        }
        playImageView.isHidden = !lastPathComponent.lowercased().hasSuffix(KFileManager.FileType.video.extString)
    }

    /**
     For movie URL, do not use this for JPG url
     */
    func generateThumbnail(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch {
            return nil
        }
    }
}
