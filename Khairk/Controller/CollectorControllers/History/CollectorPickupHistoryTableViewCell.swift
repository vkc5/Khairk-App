//
//  CollectorPickupHistoryTableViewCell.swift
//  Khairk
//
//  Created by BP-36-201-14 on 30/12/2025.
//

import UIKit

class CollectorPickupHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var pickupContainer: UIStackView!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var FoodName: UILabel!
    @IBOutlet weak var expiresSoonTag: UILabel!
    @IBOutlet weak var foodBody: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var ngoCaseContainer: UIView!
    @IBOutlet weak var ngoCaseTitle: UILabel!
    @IBOutlet weak var ngoCaseImage: UIImageView!
    @IBOutlet weak var ngoCaseDate: UILabel!
    @IBOutlet weak var ngoCaseDateEnd: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
