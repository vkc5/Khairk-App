//
//  DonorNotificationTableViewCell.swift
//  Khairk
//
//  Created by BP-36-213-17 on 04/01/2026.
//

import UIKit

class DonorNotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var notificationContainer: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        clipsToBounds = false
        contentView.clipsToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
