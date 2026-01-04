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
        let alert = UIAlertController(
            title: "Confirm Rejection",message: "Are you sure you want to reject this application? The NGO will be notified with the reason: \n\(reasonText)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Reject NGO", style: .destructive, handler: { _ in
                if let id = self.ngoID {
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
                            let notification = Notification()
                            Notification.shared.save(
                                title: "Application Update",
                                body: "Your application was not approved. Reason: \(reasonText)",
                                userId: id,
                                makeLocalNotification: true
                            )
                            self.dismiss(animated: true)
                        }
                    }
                    
                } else {
                    print("Error: Donor ID is missing")
                }

                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)

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
