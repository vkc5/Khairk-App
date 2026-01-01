//
//  DonationFormViewController.swift
//  Khairk
//
//  Created by FM on 14/12/2025.
//


import UIKit
import PhotosUI

final class DonationFormViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var foodNameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var expiryDatePicker: UIDatePicker!
    @IBOutlet weak var expiryDateLabel: UILabel!

    // MARK: - Variables
    private var selectedImage: UIImage?
    private var selectedExpiryDate: Date?

    private enum SegueID {
        static let confirmPickup = "ConfirmPickupSegue"
        static let confirmLocation = "ConfirmLocationSegue"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupImageView()
        setupTextFields()
        setupExpiryDatePicker()
        setupDismissKeyboardTap()
    }

    // MARK: - Validate before navigation (NO saving here)
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == SegueID.confirmPickup || identifier == SegueID.confirmLocation {
            return validateForm()
        }
        return true
    }

    // MARK: - Pass form data to next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let foodName = (foodNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let qtyText = (quantityTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let quantity = Int(qtyText) ?? 0
        let desc = (descriptionTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let expiryDate = selectedExpiryDate ?? expiryDatePicker.date

        if segue.identifier == SegueID.confirmPickup,
           let vc = segue.destination as? ConfirmPickupViewController {
            vc.foodName = foodName
            vc.quantity = quantity
            vc.descriptionText = desc
            vc.expiryDate = expiryDate
            vc.selectedImage = selectedImage
        }

        if segue.identifier == SegueID.confirmLocation,
           let vc = segue.destination as? ConfirmLocationViewController {
            vc.foodName = foodName
            vc.quantity = quantity
            vc.descriptionText = desc
            vc.expiryDate = expiryDate
            vc.selectedImage = selectedImage
        }
    }

    // MARK: - Validation
    private func validateForm() -> Bool {

        guard selectedImage != nil else {
            showAlert(title: "Missing Image", message: "Please upload an image for the donation.")
            return false
        }

        let foodName = (foodNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !foodName.isEmpty else {
            showAlert(title: "Missing Food Name", message: "Please enter the food name.")
            return false
        }

        let qtyText = (quantityTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let qty = Int(qtyText), qty > 0 else {
            showAlert(title: "Invalid Quantity", message: "Please enter a valid quantity.")
            return false
        }

        guard selectedExpiryDate != nil else {
            showAlert(title: "Missing Expiry Date", message: "Please select an expiry date.")
            return false
        }

        let desc = (descriptionTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !desc.isEmpty else {
            showAlert(title: "Missing Description", message: "Please enter a description.")
            return false
        }

        return true
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - TextFields
    private func setupTextFields() {
        foodNameTextField.delegate = self
        quantityTextField.delegate = self
        descriptionTextField.delegate = self

        quantityTextField.keyboardType = .numberPad
        foodNameTextField.returnKeyType = .next
        quantityTextField.returnKeyType = .next
        descriptionTextField.returnKeyType = .done
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == foodNameTextField {
            quantityTextField.becomeFirstResponder()
        } else if textField == quantityTextField {
            descriptionTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    // MARK: - Expiry Date Picker
    private func setupExpiryDatePicker() {
        expiryDatePicker.datePickerMode = .date
        expiryDatePicker.preferredDatePickerStyle = .wheels
        expiryDatePicker.minimumDate = Date()

        selectedExpiryDate = expiryDatePicker.date

        expiryDateLabel?.semanticContentAttribute = .forceLeftToRight
        expiryDateLabel?.textAlignment = .left
        expiryDateLabel?.text = formatDate(expiryDatePicker.date)

        expiryDatePicker.addTarget(self, action: #selector(expiryDateChanged(_:)), for: .valueChanged)
    }

    @objc private func expiryDateChanged(_ sender: UIDatePicker) {
        selectedExpiryDate = sender.date
        expiryDateLabel?.text = formatDate(sender.date)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }

    // MARK: - Keyboard dismiss
    private func setupDismissKeyboardTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Image Picker
    private func setupImageView() {
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.clipsToBounds = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(uploadImageTapped))
        uploadImageView.addGestureRecognizer(tap)
    }

    @objc private func uploadImageTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension DonationFormViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self = self, let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self.selectedImage = image
                self.uploadImageView.image = image
            }
        }
    }
}
