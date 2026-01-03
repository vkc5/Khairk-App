//
//  GroupCell.swift
//  Khairk
//
//  Created by FM on 15/12/2025.
//

import UIKit

final class GroupCell: UITableViewCell {

    // MARK: - Outlets (connect from storyboard)
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Make the cell background transparent so the card looks like a floating card.
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        // Card styling (rounded corners + border + subtle shadow).
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray5.cgColor
        cardView.backgroundColor = .systemBackground

        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.layer.masksToBounds = false

        // Badge styling.
        
            statusLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            statusLabel.textAlignment = .center
            statusLabel.layer.cornerRadius = 10
            statusLabel.clipsToBounds = true

            // padding 
            statusLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([statusLabel.heightAnchor.constraint(equalToConstant: 18)])
            statusLabel.setContentHuggingPriority(.required, for: .horizontal)
            statusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        

        statusLabel.layer.cornerRadius = 10
        statusLabel.clipsToBounds = true
        statusLabel.textAlignment = .center
    }

    // MARK: - Configure
    func configure(with item: DonationGroupItem) {
        nameLabel.text = item.name
        frequencyLabel.text = item.frequency
        statusLabel.text = item.status.rawValue

        switch item.status {
        case .active:
            statusLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.15)
            statusLabel.textColor = UIColor.systemGreen
        case .paused:
            statusLabel.backgroundColor = UIColor.systemGray5
            statusLabel.textColor = UIColor.systemGray
        }
    }
}
