//
//  DonationFormViewController.swift
//  Khairk
//
//  Created by FM on 14/12/2025.
//

import UIKit
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

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

    // MARK: - ID Linking (Optional: may be passed from other screen)
    var caseId: String?
    var ngoId: String?

    // Current logged-in donor ID
    private var donorId: String? {
        return Auth.auth().currentUser?.uid
    }

    private enum SegueID {
        static let confirmPickup = "ConfirmPickupSegue"
        static let confirmLocation = "ConfirmLocationSegue"
    }

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DonationForm opened with caseId=\(caseId ?? "nil"), ngoId=\(ngoId ?? "nil")")
        setupImageView()
        setupTextFields()
        setupExpiryDatePicker()
        setupDismissKeyboardTap()

        // ✅ IMPORTANT: If caseId not passed, fetch default active case from Firestore
        ensureCaseAndNgoIds()
    }

    // MARK: - Fetch IDs (No need to touch ngocases VC)
    private func ensureCaseAndNgoIds() {

        // 1) إذا caseId موجودة بس ngoId ناقصة -> جيبي ngoID من نفس الدوكمنت
        if let caseId = caseId, !caseId.isEmpty {
            if let ngoId = ngoId, !ngoId.isEmpty {
                print("✅ IDs already set. caseId=\(caseId), ngoId=\(ngoId)")
                return
            }

            // fetch ngoID by caseId
            fetchNgoId(for: caseId)
            return
        }

        // 2) إذا caseId مو موجودة -> جيبي Active case من Firestore
        fetchActiveCase()
    }

    private func fetchActiveCase() {
        Firestore.firestore()
            .collection("ngoCases")
            .whereField("status", isEqualTo: "active")
            .limit(to: 1)
            .getDocuments { [weak self] snap, err in

                if let err = err {
                    print("❌ fetchActiveCase error:", err)
                    return
                }

                guard let doc = snap?.documents.first else {
                    print("❌ No active case found in ngoCases")
                    return
                }

                let data = doc.data()
                let fetchedNgoId = data["ngoID"] as? String // IMPORTANT: same name as Firestore

                self?.caseId = doc.documentID
                self?.ngoId = fetchedNgoId

                print("✅ Loaded active case. caseId=\(doc.documentID), ngoId=\(fetchedNgoId ?? "nil")")
            }
    }

    private func fetchNgoId(for caseId: String) {
        Firestore.firestore()
            .collection("ngoCases")
            .document(caseId)
            .getDocument { [weak self] snap, err in

                if let err = err {
                    print("❌ Failed to fetch ngoID:", err)
                    return
                }
                guard let data = snap?.data() else {
                    print("❌ Case document not found for caseId:", caseId)
                    return
                }

                let fetchedNgoId = data["ngoID"] as? String // IMPORTANT: same name as Firestore
                self?.ngoId = fetchedNgoId

                print("✅ Fetched ngoID from Firestore:", fetchedNgoId ?? "nil")
            }
    }

    // MARK: - Validate before navigation (NO saving here)
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {

        if identifier == SegueID.confirmPickup || identifier == SegueID.confirmLocation {

            // ✅ if IDs not ready yet, try load them and stop segue
            if caseId == nil || caseId?.isEmpty == true || ngoId == nil || ngoId?.isEmpty == true {
                ensureCaseAndNgoIds()
                showAlert(title: "Please wait", message: "Loading case info… try again in a second.")
                return false
            }

            // ✅ Validate form after IDs are ready
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

            vc.donorId = donorId
            vc.caseId = caseId
            vc.ngoId = ngoId
        }

        if segue.identifier == SegueID.confirmLocation,
           let vc = segue.destination as? ConfirmLocationViewController {

            vc.foodName = foodName
            vc.quantity = quantity
            vc.descriptionText = desc
            vc.expiryDate = expiryDate
            vc.selectedImage = selectedImage

            vc.donorId = donorId
            vc.caseId = caseId
            vc.ngoId = ngoId
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
