//
//  AdminNGOVerificationTableViewCell.swift
//  Khairk
//
//  Created by BP-19-130-16 on 31/12/2025.
//

import UIKit

class AdminNGOVerificationTableViewCell: UITableViewCell {

    @IBOutlet weak var ngoContainer: UIView!
    @IBOutlet weak var ngoImage: UIImageView!
    @IBOutlet weak var ngoName: UILabel!
    @IBOutlet weak var ngoStatusIcon: UIImageView!
    @IBOutlet weak var ngoStatus: UILabel!
    @IBOutlet weak var ngoJoinDate: UILabel!
    @IBOutlet weak var ngoArea: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
