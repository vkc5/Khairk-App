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
        ngoName.numberOfLines = 0
        ngoName.lineBreakMode = .byWordWrapping
        ngoName.setContentCompressionResistancePriority(.init(751), for: .vertical)
        ngoName.setContentCompressionResistancePriority(.init(751), for: .horizontal)
        ngoName.setContentHuggingPriority(.init(249), for: .horizontal)
        
        ngoStatus.setContentCompressionResistancePriority(.init(752), for: .horizontal)
        ngoStatusIcon.setContentCompressionResistancePriority(.init(752), for: .horizontal)
        ngoStatus.setContentHuggingPriority(.init(251), for: .horizontal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
