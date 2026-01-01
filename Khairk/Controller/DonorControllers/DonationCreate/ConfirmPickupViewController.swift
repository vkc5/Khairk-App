//
//  ConfirmPickupViewController.swift
//  Khairk
//
//  Created by FM on 15/12/2025.
//

import UIKit

final class ConfirmPickupViewController: UIViewController {

    // MARK: - Incoming form data
    var foodName: String = ""
    var quantity: Int = 0
    var descriptionText: String = ""
    var expiryDate: Date = Date()
    var selectedImage: UIImage?

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

        let pickupTime = pickupDatePicker.date
        nextButton.isEnabled = false

        CloudinaryService.shared.uploadImage(image) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let urlString):

                    DonationService.shared.createDonation(
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
                                self.showSuccessAlert {
                                    self.navigationController?.popViewController(animated: true)
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
}
