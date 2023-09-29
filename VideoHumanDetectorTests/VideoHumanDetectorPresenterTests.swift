//
//  VideoHumanDetectorTests.swift
//  VideoHumanDetectorTests
//
//  Created by Wontai Ki on 9/19/23.
//

import XCTest
@testable import VideoHumanDetector

// This app, we need to PHAsset in many points to test smoothly, and It's a little tricky.
// And I'll show the conceptial code to use mock.
final class VideoHumanDetectorPresenterTests: XCTestCase {
    var presenter: LibraryPagePresenter!
    var mockView = MockLibraryPageViewController()

    override func setUpWithError() throws {
        presenter = LibraryPagePresenter(view: mockView)
    }

    override func tearDownWithError() throws {
        presenter = nil
    }

    func testVideoProjectSelected() throws {
        // Given
        let url = URL(filePath: "file://test/test.mov")
        XCTAssertFalse(mockView.pushVideoProcessingPageCalled)

        // When
        presenter.projectSelected(projectURL: url)

        // Then
        XCTAssertTrue(mockView.presentPlayerCalled)
        XCTAssertEqual(mockView.projectURLParam!, url)
    }

    func testImageProjectSelected() throws {
        // Given
        let url = URL(filePath: "file://test/test.jpg")

        // When
        presenter.projectSelected(projectURL: url)

        // Then
        XCTAssertTrue(mockView.pushImageViewPageCalled)
        XCTAssertEqual(mockView.projectURLParam!, url)
    }
}
