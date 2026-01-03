//
//  TopNgoCell.swift
//  Khairk
//
//  Created by vkc5 on 02/01/2026.
//

import UIKit

final class TopNgoCell: UICollectionViewCell {
    @IBOutlet weak var ngoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.clipsToBounds = true

        ngoImageView.clipsToBounds = true
        ngoImageView.layer.cornerRadius = 8
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ngoImageView.image = UIImage(systemName: "photo")
    }

    func configure(name: String, count: Int, imageURL: String?) {
        nameLabel.text = name
        countLabel.text = "Cases: \(count)"

        if let urlStr = imageURL, let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self, let data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async { self.ngoImageView.image = img }
            }.resume()
        } else {
            ngoImageView.image = UIImage(systemName: "photo")
        }
    }
}


