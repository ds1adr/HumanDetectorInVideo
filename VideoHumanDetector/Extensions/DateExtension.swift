//
//  File.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/23/23.
//

import Foundation

extension Date {
    func filenameString() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd-hhmmss"
        return dateFormatter.string(from: self)
    }
}
