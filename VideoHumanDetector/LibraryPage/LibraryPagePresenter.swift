//
//  LibraryPagePresenter.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/19/23.
//

import Foundation
import Photos

protocol LibraryPagePresenting {
    func viewAppears()
    func segmentedControlChanged(index: Int)
    func projectSelected(projectURL: URL)
    func photoLibrarySelected(asset: PHAsset)
}

class LibraryPagePresenter: LibraryPagePresenting {

    weak var view: LibraryPageViewable?
    var selectedContentType: PHAssetMediaType = .unknown

    init(view: LibraryPageViewable? = nil) {
        self.view = view
    }

    /**

     */
    func viewAppears() {
        fetchProjectFiles()
        checkAndGetPhotoLibraryPermission { [weak self] granted in
            guard let self else { return }
            if granted {
                fetchLibraryAssets()
            } else {
                Task { @MainActor in
                    self.view?.displayAlert(title: "Information", message: "To use the app, permission is required.")
                }
            }
        }
    }

    /**
     For first section, fetch project files from local document directory
     */
    private func fetchProjectFiles() {
        let urls = KFileManager.getFilesInDocument()
        switch selectedContentType {
        case .image:
            let filtedResult = urls.filter { url in
                let lastComponent = url.lastPathComponent
                return lastComponent.hasSuffix(KFileManager.FileType.image.extString)
            }
            view?.updateProjectURLs(urls: filtedResult)
        case .video:
            let filteredResult = urls.filter { url in
                let lastComponent = url.lastPathComponent
                return lastComponent.hasSuffix(KFileManager.FileType.video.extString)
            }
            view?.updateProjectURLs(urls: filteredResult)
        default:
            view?.updateProjectURLs(urls: urls)
        }
    }

    /**
     Segmented control value changed
     */
    func segmentedControlChanged(index: Int) {
        switch index {
        case 0:
            selectedContentType = .unknown
        case 1:
            selectedContentType = .video
        case 2:
            selectedContentType = .image
        default:
            break
        }
        fetchProjectFiles()
        fetchLibraryAssets()
    }

    /**
     From CollectionView didSelect - Project result selected
     */
    func projectSelected(projectURL: URL) {
        guard let view else { return }
        if projectURL.lastPathComponent.hasSuffix(KFileManager.FileType.image.extString) {
            view.pushImageViewPage(projectURL: projectURL)
        } else if projectURL.lastPathComponent.hasSuffix(KFileManager.FileType.video.extString) {
            view.presentPlayer(projectURL: projectURL)
        }
    }

    /**
     From CollectionView didSelect - Photo library
     */
    func photoLibrarySelected(asset: PHAsset) {
        switch asset.mediaType {
        case .image:
            view?.pushImageProcessingPage(asset: asset)
        case .video:
            view?.pushVideoProcessingPage(asset: asset)
        default:
            break
        }
    }

    /**
     Get Permission to access photo library
     - Parameters completion param true: granted
     */
    private func checkAndGetPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            completion(true)
            return
        }

        PHPhotoLibrary.requestAuthorization { status in
            completion(status == .authorized ? true : false)
        }
    }

    /**
     From Photo libraray
     */
    private func fetchLibraryAssets() {
        let assetOptions = PHFetchOptions()
        assetOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        if selectedContentType != .unknown {
            assetOptions.predicate  = NSPredicate(format: "mediaType = %d", selectedContentType.rawValue)
        }

        let assets = PHAsset.fetchAssets(with: assetOptions)
        view?.updateAssets(assets: assets)
    }
}
