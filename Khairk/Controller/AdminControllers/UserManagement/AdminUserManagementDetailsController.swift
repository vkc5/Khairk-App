//
//  AdminUserManagementDetailsController.swift
//  Khairk
//
//  Created by BP-36-213-17 on 01/01/2026.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AdminUserManagementDetailsController: UIViewController {
    var donorID: String?
    @IBOutlet weak var donorImage: UIImageView!
    @IBOutlet weak var donorName: UILabel!
    @IBOutlet weak var donorJoinDate: UILabel!
    @IBOutlet weak var donorNameS: UILabel!
    @IBOutlet weak var donorEmail: UILabel!
    @IBOutlet weak var donorPhone: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        donorImage.layer.cornerRadius = donorImage.frame.width / 2
        donorImage.layer.borderWidth = 0.5
        donorImage.layer.masksToBounds = true
        donorImage.contentMode = .scaleAspectFill
        donorImage.tintColor = .mainBrand500
        if let id = donorID {
            print("Received Donor ID: \(id)")
            fetchDonorDetails()
        }
        // Do any additional setup after loading the view.
    }
    private func fetchDonorDetails() {
        guard let donorID = donorID else {
            print("ID is nil")
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(donorID).getDocument { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
  
            guard let snapshot = querySnapshot,
                  let data = snapshot.data(),
                  let donor = User(id: snapshot.documentID, dictionary: data)
            else {
                print("Ngo not found or parsing failed")
                return
            }
            

            // Reload table view on main thread
            DispatchQueue.main.async {
                if let url = donor.profileImageUrl, !url.isEmpty {
                    self.donorImage.loadImage(from: url)
                } else {
                    self.donorImage.image = UIImage(systemName: "person.circle.fill")
                    self.donorImage.tintColor = .mainBrand500
                }
                
                self.donorName.text = donor.name
                self.donorEmail.text = donor.email
                self.donorPhone.text = donor.phone
                self.donorNameS.text = donor.name
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_BH")
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                self.donorJoinDate.text = "Joind on \(dateFormatter.string(from: donor.createdAt))"
            }
            
        }
    }
    
    
    @IBAction func openSendMassage(_ sender: Any) {
        performSegue(withIdentifier: "ShowSendMassage", sender: donorID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSendMassage" {
                if let messageVC = segue.destination as? AdminUserManagementSendMassageController {
                    if let id = sender as? String {
                        messageVC.donorID = id
                        
                        messageVC.donorName = self.donorName.text
                        messageVC.donorImage = self.donorImage.image
                        messageVC.donorJoinDateString = self.donorJoinDate.text
                    }
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
