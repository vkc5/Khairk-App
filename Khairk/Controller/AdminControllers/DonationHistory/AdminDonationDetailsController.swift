//
//  AdminDonationDetailsController.swift
//  Khairk
//
//  Created by BP-19-130-16 on 28/12/2025.
//

import UIKit
import FirebaseFirestore

class AdminDonationDetailsController: UIViewController {
    var donationID: String?

    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var foodNameHeaderLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var expiresSoonContainer: UIView!
    @IBOutlet weak var expiresSoonAlert: UIView!
    @IBOutlet weak var expireSoonText: UITextView!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var donationTypeLabel: UILabel!
    @IBOutlet weak var Quantity: UILabel!
    @IBOutlet weak var expireDateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var donarImage: UIImageView!
    @IBOutlet weak var donerName: UILabel!
    @IBOutlet weak var donerEmail: UILabel!
    @IBOutlet weak var donerPhoneNumber: UILabel!
    @IBOutlet weak var ngoImage: UIImageView!
    @IBOutlet weak var ngoName: UILabel!
    @IBOutlet weak var ngoEmail: UILabel!
    @IBOutlet weak var ngoPhoneNumber: UILabel!
    @IBOutlet weak var ngoCaseImage: UIImageView!
    @IBOutlet weak var ngoCaseTitle: UILabel!
    @IBOutlet weak var ngoCaseBody: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        if let id = donationID {
            print("Received Donation ID: \(id)")
            fetchDonationDetails()
        }
        // Do any additional setup after loading the view.
    }
    private func uiSetup() {
        foodImage.contentMode = .scaleAspectFill
        foodImage.clipsToBounds = true
        foodImage.layer.cornerRadius = 5
        expiresSoonAlert.layer.cornerRadius = 5
        expiresSoonAlert.layer
    }
    private func fetchDonationDetails() {
        guard let donationID = donationID else {
            print("Donation ID is nil")
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("donations").document(donationID).getDocument { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
  
            guard let snapshot = querySnapshot,
                  let data = snapshot.data(),
                  let donation = Donation(id: snapshot.documentID, dictionary: data)
            else {
                print("Donation not found or parsing failed")
                return
            }
            

            // Reload table view on main thread
            DispatchQueue.main.async {
                self.foodImage.loadImage(from: donation.imageURL)
                self.idLabel.text = "ID: \(donation.id)"
                self.foodNameLabel.text = donation.foodName
                self.foodNameHeaderLabel.text = donation.foodName
                self.statusLabel.text = donation.status
                self.createdAtLabel.text = donation.createdAt.description
                self.donationTypeLabel.text = donation.donationType
                self.Quantity.text = "\(donation.quantity)"
                self.expireDateLabel.text = donation.expiryDate.description
                self.descriptionLabel.text = donation.description
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
