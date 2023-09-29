//
//  CollectionHeaderView.swift
//  VideoHumanDetector
//
//  Created by Wontai Ki on 9/23/23.
//

import UIKit

class CollectionHeaderView: UICollectionReusableView {

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.text = title
    }
}
