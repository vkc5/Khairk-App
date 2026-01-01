//
//  AdminUserManagementTableViewCell.swift
//  Khairk
//
//  Created by BP-36-213-17 on 01/01/2026.
//

import UIKit

class AdminUserManagementTableViewCell: UITableViewCell {

    @IBOutlet weak var donorimage: UIImageView!
    @IBOutlet weak var joinDate: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var donorContainer: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
