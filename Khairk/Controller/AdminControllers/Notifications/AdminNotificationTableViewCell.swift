//
//  AdminNotificationTableViewCell.swift
//  Khairk
//
//  Created by BP-19-130-16 on 21/12/2025.
//

import UIKit

class AdminNotificationTableViewCell: UITableViewCell {

    
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
