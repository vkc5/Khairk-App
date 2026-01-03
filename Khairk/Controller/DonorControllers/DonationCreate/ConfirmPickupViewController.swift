//
//  ConfirmPickupViewController.swift
//  Khairk
//
//  Created by FM on 15/12/2025.
//

import UIKit
import FirebaseAuth

final class ConfirmPickupViewController: UIViewController {

    // MARK: - Incoming form data
    var foodName: String = ""
    var quantity: Int = 0
    var descriptionText: String = ""
    var expiryDate: Date = Date()
    var selectedImage: UIImage?
    private var createdDonationId: String?

    // ✅ ADD HERE
    var donorId: String?
    var caseId: String?
    var ngoId: String?

    @IBOutlet private weak var pickupDatePicker: UIDatePicker!
    @IBOutlet private weak var pickupDateLabel: UILabel!
    @IBOutlet private weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPickupDatePicker()
        updatePickupLabel(with: pickupDatePicker.date)
    }

    private func setupPickupDatePicker() {
        pickupDatePicker.datePickerMode = .dateAndTime
        pickupDatePicker.minimumDate = Date()
        pickupDatePicker.locale = Locale(identifier: "en_US_POSIX")

        if #available(iOS 13.4, *) {
            pickupDatePicker.preferredDatePickerStyle = .wheels
        }

        pickupDatePicker.addTarget(self, action: #selector(pickupDateChanged(_:)), for: .valueChanged)
    }

    @objc private func pickupDateChanged(_ sender: UIDatePicker) {
        updatePickupLabel(with: sender.date)
    }

    @IBAction private func nextTapped(_ sender: UIButton) {
        guard let image = selectedImage else {
            showAlert(title: "Error", message: "Missing selected image.")
            return
        }
        
        guard let caseId = self.caseId, !caseId.isEmpty,
              let ngoId = self.ngoId, !ngoId.isEmpty else {
            showAlert(title: "Missing IDs", message: "caseId / ngoId not found. Go back and select a case again.")
            return
        }


        let pickupTime = pickupDatePicker.date
        nextButton.isEnabled = false

        CloudinaryService.shared.uploadImage(image) { [weak self] result in
            guard let self = self else { return }
            
            // Ensure we have a valid donor ID for linking
            guard let uid = Auth.auth().currentUser?.uid else {
                self.nextButton.isEnabled = true
                self.showAlert(title: "Error", message: "Missing logged-in user.")
                return
            }



            DispatchQueue.main.async {
                switch result {
                case .success(let urlString):

                    DonationService.shared.createDonation(
                        
                        donorId: uid,              // ✅ REQUIRED
                        caseId: caseId,       // ✅ REQUIRED
                        ngoId: ngoId,         // ✅ REQUIRED
                        
                        
                        foodName: self.foodName,
                        quantity: self.quantity,
                        expiryDate: self.expiryDate,
                        description: self.descriptionText,
                        donationType: "pickup",
                        imageURL: urlString,
                        pickupTime: pickupTime
                    ) { saveResult in
                        DispatchQueue.main.async {
                            self.nextButton.isEnabled = true

                            switch saveResult {
                            case .success(let donationId):
                                print("Saved donation:", donationId)
                                self.createdDonationId = donationId
                                self.showSuccessAlert {
                                    self.performSegue(withIdentifier: "toRating", sender: nil)
                                }

                            case .failure(let error):
                                self.showAlert(title: "Save Failed", message: error.localizedDescription)
                            }
                        }
                    }

                case .failure(let error):
                    self.nextButton.isEnabled = true
                    self.showAlert(title: "Cloudinary Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func goToDashboard() {
        // If your app uses Tab Bar, go to the first tab (Dashboard)
        if let tab = self.tabBarController {
            tab.selectedIndex = 0
            self.navigationController?.popToRootViewController(animated: true)
            return
        }

        // If it's only NavigationController, go back to root (Dashboard)
        self.navigationController?.popToRootViewController(animated: true)
    }


    private func updatePickupLabel(with date: Date) {
        pickupDateLabel.text = formatDateTime(date)
    }

    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM yyyy   h:mm a"
        return formatter.string(from: date)
    }

    private func showSuccessAlert(onOK: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Thank you for Donating!",
            message: "Your pickup request has been submitted successfully.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in onOK() })
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRating" {

            let dest = segue.destination
            let ratingVC = (dest as? RatingViewController)
                ?? (dest as? UINavigationController)?.topViewController as? RatingViewController

            guard let vc = ratingVC else { return }

            vc.ngoId = self.ngoId
            vc.caseId = self.caseId
            vc.donationId = self.createdDonationId
            vc.donorId = Auth.auth().currentUser?.uid
        }
    }

}
