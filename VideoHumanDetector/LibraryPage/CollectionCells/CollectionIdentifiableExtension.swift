//
//  CollectionIdentifiableExtension.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/19/23.
//

import UIKit

protocol CollectionIdentifiable {
    static var reuseIdentifier: String { get }
}

extension CollectionIdentifiable {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}

extension UICollectionViewCell : CollectionIdentifiable {}

extension UICollectionReusableView : CollectionIdentifiable {}
