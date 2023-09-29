//
//  KFileManager.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/22/23.
//

import Foundation
import Photos

class KFileManager {

    enum FileType {
        case image
        case video

        /**
         File extension definition
         */
        var extString: String {
            switch self {
            case .image:
                return ".jpg"
            case .video:
                return ".mov"
            }
        }
    }

    static func getFilesInDocument() -> [URL] {
        do {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            guard let documentDirectory: URL = urls.first else {
                fatalError("documentDir Error")
            }

            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(
                at: documentDirectory,
                includingPropertiesForKeys: nil
            )

            return directoryContents.sorted(by: { lhs, rhs in
                let lhsComponent = lhs.lastPathComponent
                let rhsComponent = rhs.lastPathComponent
                return lhsComponent > rhsComponent
            })

        } catch {
            print(error)
        }
        return []
    }

    static func makeFilename(type: FileType) -> URL {
        let fileManager = FileManager.default

        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        guard let documentDirectory: URL = urls.first else {
            fatalError("documentDir Error")
        }

        let videoOutputURL = documentDirectory.appendingPathComponent("\(Date().filenameString())\(type.extString)")

        if fileManager.fileExists(atPath: videoOutputURL.path) {
            do {
                try fileManager.removeItem(atPath: videoOutputURL.path)
            } catch {
                fatalError("Unable to delete file: \(error) : \(#function)\(type.extString)")
            }
        }

        return videoOutputURL
    }
}
