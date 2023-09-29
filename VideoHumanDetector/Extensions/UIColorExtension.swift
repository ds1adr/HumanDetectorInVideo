//
//  UIColorExtension.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/21/23.
//

import UIKit

extension UIColor {
    func image(_ size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
