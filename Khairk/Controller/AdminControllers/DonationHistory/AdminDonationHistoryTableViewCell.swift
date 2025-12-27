//
//  AdminDonationHistoryTableViewCell.swift
//  Khairk
//
//  Created by BP-19-130-16 on 27/12/2025.
//

import UIKit

class AdminDonationHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var expiresSoonTag: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        expiresSoonTag.text = "Expires Soon"
        expiresSoonTag.textColor = .white
        expiresSoonTag.backgroundColor = .systemRed
        expiresSoonTag.layer.cornerRadius = 8
        expiresSoonTag.clipsToBounds = true 
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
