//
//  AdminDonationDetailsController.swift
//  Khairk
//
//  Created by BP-19-130-16 on 28/12/2025.
//

import UIKit

class AdminDonationDetailsController: UIViewController {
    var donationID: String?

    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var ID: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let id = donationID {
            print("Received Donation ID: \(id)")
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
