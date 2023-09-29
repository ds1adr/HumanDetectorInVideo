//
//  MockLibraryPagePresenter.swift
//  VideoHumanDetectorTests
//
//  Created by Wontai Ki on 9/25/23.
//

@testable import VideoHumanDetector
import Foundation
import Photos

class MockLibraryPagePresenter: LibraryPagePresenting {
    var viewAppearsCalled = false
    func viewAppears() {
        viewAppearsCalled = true
    }

    var segmentedControlChangedCalled = false
    var indexParam: Int?
    func segmentedControlChanged(index: Int) {
        indexParam = index
        segmentedControlChangedCalled = true
    }

    var projectSelectedCalled = false
    var projectURLparam: URL?
    func projectSelected(projectURL: URL) {
        projectURLparam = projectURL
        projectSelectedCalled = true
    }

    var photoLibrarySelectedCalled = false
    var assetParam: PHAsset?
    func photoLibrarySelected(asset: PHAsset) {
        assetParam = asset
        photoLibrarySelectedCalled = true
    }
}
