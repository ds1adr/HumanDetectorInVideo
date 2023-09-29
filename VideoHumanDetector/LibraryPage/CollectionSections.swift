//
//  CollectionSections.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/24/23.
//

import Photos
import UIKit

protocol Section {
    /**
     To display title in section header
     */
    var sectionTitle: String { get }
    var itemCount: Int { get }

    func cell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
}

class MyProjectSection: Section {
    private var projectURLs: [URL] = []

    var sectionTitle: String {
        NSLocalizedString("My Projects", comment: "")
    }

    var itemCount: Int {
        projectURLs.count
    }

    init(projectURLs: [URL]) {
        self.projectURLs = projectURLs
    }

    func cell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCollectionViewCell.reuseIdentifier, for: indexPath)
        let url = projectURLs[indexPath.item]
        (cell as? AssetCollectionViewCell)?.configure(url: url)
        return cell
    }

    func getProjectURL(index: Int) -> URL? {
        guard index < projectURLs.count else { return nil }
        return projectURLs[index]
    }
}

class PhotoLibrarySection: Section {
    private var currentAssets: PHFetchResult<PHAsset>

    var sectionTitle: String {
        NSLocalizedString("Photo Library", comment: "")
    }

    var itemCount: Int {
        currentAssets.count
    }

    init(currentAssets: PHFetchResult<PHAsset>) {
        self.currentAssets = currentAssets
    }

    func cell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCollectionViewCell.reuseIdentifier, for: indexPath)
        let asset = currentAssets[indexPath.item]
        (cell as? AssetCollectionViewCell)?.configure(asset: asset)
        return cell
    }

    func getAseet(index: Int) -> PHAsset? {
        guard index < currentAssets.count else { return nil }
        return currentAssets[index]
    }
}
