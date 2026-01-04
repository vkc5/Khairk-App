//
//  TopDonorCell.swift
//  Khairk
//
//  Created by vkc5 on 02/01/2026.
//

import UIKit

final class TopDonorCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.clipsToBounds = true
    }

    func configure(name: String, count: Int) {
        nameLabel.text = name
        countLabel.text = "Donation \(count)"
    }
}


