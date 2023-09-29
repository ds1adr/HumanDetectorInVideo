//
//  MockLibraryPageViewController.swift
//  VideoHumanDetectorTests
//
//  Created by Wontai Ki on 9/25/23.
//

@testable import VideoHumanDetector
import Photos
import UIKit

class MockLibraryPageViewController: UIViewController, LibraryPageViewable {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var updateProjectURLsCalled = false
    var urlsParam: [URL]?
    func updateProjectURLs(urls: [URL]) {
        urlsParam = urls
    }

    var updateAssetsCalled = false
    var assetsParam: PHFetchResult<PHAsset>?
    func updateAssets(assets: PHFetchResult<PHAsset>) {
        assetsParam = assets
        updateAssetsCalled = true
    }

    var pushImageProcessingPageCalled = false
    var assetParam: PHAsset?
    func pushImageProcessingPage(asset: PHAsset) {
        assetParam = asset
        pushImageProcessingPageCalled = true
    }

    var pushVideoProcessingPageCalled = false
    func pushVideoProcessingPage(asset: PHAsset) {
        assetParam = asset
        pushVideoProcessingPageCalled = true
    }

    var pushImageViewPageCalled = false
    var projectURLParam: URL?
    func pushImageViewPage(projectURL: URL) {
        projectURLParam = projectURL
        pushImageViewPageCalled = true
    }

    var presentPlayerCalled = false
    func presentPlayer(projectURL: URL) {
        projectURLParam = projectURL
        presentPlayerCalled = true
    }
}

