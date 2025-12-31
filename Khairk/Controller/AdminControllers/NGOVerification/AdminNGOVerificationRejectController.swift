//
//  AdminNGOVerificationRejectController.swift
//  Khairk
//
//  Created by BP-36-213-17 on 31/12/2025.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AdminNGOVerificationRejectController: UIViewController {
    
    var ngoID: String?
    @IBOutlet weak var reason: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Reject screen received ngoID:", ngoID ?? "nil")

        title = "Reject NGO Account"
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func submit(_ sender: Any) {
        guard let ngoID = ngoID else {
            print("ngo ID is nil")
            return
        }

        let db = Firestore.firestore()
        let reasonText = reason.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        db.collection("users").document(ngoID).updateData([
            "applicationStatus": "rejected",
            "rejection": [
                "reason": reasonText,
                "rejectedAt": Timestamp(date: Date()),
            ]
        ]) { error in
            if let error = error {
                print("Failed: \(error)")
            } else {
            }
        }

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
