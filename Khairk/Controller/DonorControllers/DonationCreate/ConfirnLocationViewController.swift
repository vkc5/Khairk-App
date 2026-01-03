//
//  ConfirnLocationViewController.swift
//  Khairk
//
//  Created by FM on 14/12/2025.
//
//

import UIKit
import MapKit
import FirebaseAuth


final class ConfirmLocationViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Incoming form data
    var foodName: String = ""
    var quantity: Int = 0
    var descriptionText: String = ""
    var expiryDate: Date = Date()
    var selectedImage: UIImage?
    private var createdDonationId: String?

    // passing
    var donorId: String?
    var caseId: String?
    var ngoId: String?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var serviceAreaTextField: UITextField!
    @IBOutlet weak var buildingNumberTextField: UITextField!
    @IBOutlet weak var blockTextField: UITextField!
    @IBOutlet weak var streetTextField: UITextField!

    private var confirmedCoordinate: CLLocationCoordinate2D?
    private var pinAnnotation: MKPointAnnotation?

    private let serviceAreas = [
        "Manama","Juffair","Adliya","Seef","Sanabis","Daih","Jidhafs","Salmaniya","Hoora","Diplomatic Area",
        "Muharraq","Hidd","Busaiteen","Galali","Amwaj Islands","Arad","Samaheej","Diyar Al Muharraq",
        "Budaiya","Diraz","Barbar","Saar","Jasra","Hamala","Janabiyah","Aali","Bani Jamra","Karranah","Shakhura","Abu Saiba","Ma'ameer",
        "Riffa","East Riffa","West Riffa","Isa Town","Sitra","Zallaq","Awali","Askar","Jaw","Safra","Al Areen","Durrat Al Bahrain",
        "Hawar Islands","Reef Island","Bahrain Bay"
    ]
    private let serviceAreaPicker = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapTapToDropPin()
        setupTextFields()
        setupServiceAreaDropdown()
        setupDismissKeyboardTap()
    }

    private func setupMapTapToDropPin() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        mapView.addGestureRecognizer(tap)

        let start = CLLocationCoordinate2D(latitude: 26.2285, longitude: 50.5860)
        let region = MKCoordinateRegion(center: start, latitudinalMeters: 12000, longitudinalMeters: 12000)
        mapView.setRegion(region, animated: false)
    }

    @objc private func mapTapped(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

        confirmedCoordinate = coordinate

        if let oldPin = pinAnnotation {
            mapView.removeAnnotation(oldPin)
        }

        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = "Confirmed Location"
        mapView.addAnnotation(pin)
        pinAnnotation = pin
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        guard validateForm() else { return }
        guard let image = selectedImage else {
            showAlert(title: "Error", message: "Missing selected image.")
            return
        }
        guard let coordinate = confirmedCoordinate else {
            showAlert(title: "Error", message: "Missing confirmed coordinate.")
            return
        }
        
        guard let caseId = self.caseId, !caseId.isEmpty,
              let ngoId = self.ngoId, !ngoId.isEmpty else {
            showAlert(title: "Missing IDs", message: "caseId / ngoId not found. Go back and select a case again.")
            return
        }

        
        // Ensure we have a valid donor ID for linking
        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert(title: "Error", message: "Missing logged-in user.")
            return
        }

        let area = (serviceAreaTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let building = (buildingNumberTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let block = (blockTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let street = (streetTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        CloudinaryService.shared.uploadImage(image) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let urlString):

                    DonationService.shared.createDonation(
                        
                        donorId: uid,         // ✅ REQUIRED
                        caseId: caseId,       // ✅ REQUIRED
                        ngoId: ngoId,         // ✅ REQUIRED
                        
                        foodName: self.foodName,
                        quantity: self.quantity,
                        expiryDate: self.expiryDate,
                        description: self.descriptionText,
                        donationType: "delivery",
                        imageURL: urlString,
                        serviceArea: area,
                        buildingNumber: building,
                        block: block,
                        street: street,
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    ) { saveResult in
                        DispatchQueue.main.async {
                            switch saveResult {
                            case .success(let donationId):
                                self.createdDonationId = donationId
                                self.showAlert(
                                    title: "Thank you for Donating!",
                                    message: "Your delivery location and image have been submitted successfully."
                                ) {
                                    self.performSegue(withIdentifier: "toRating", sender: nil)
                                }

                            case .failure(let error):
                                self.showAlert(title: "Save Failed", message: error.localizedDescription)
                            }
                        }
                    }

                case .failure(let error):
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


    private func validateForm() -> Bool {

        guard confirmedCoordinate != nil else {
            showAlert(title: "Missing Location", message: "Please confirm your location on the map.")
            return false
        }

        let area = (serviceAreaTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !area.isEmpty else {
            showAlert(title: "Missing Service Area", message: "Please select a service area.")
            return false
        }

        let building = (buildingNumberTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !building.isEmpty else {
            showAlert(title: "Missing Building Number", message: "Please enter your building number.")
            return false
        }

        let block = (blockTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !block.isEmpty else {
            showAlert(title: "Missing Block", message: "Please enter your block.")
            return false
        }

        let street = (streetTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !street.isEmpty else {
            showAlert(title: "Missing Street", message: "Please enter your street.")
            return false
        }

        return true
    }

    private func setupTextFields() {
        serviceAreaTextField.delegate = self
        buildingNumberTextField.delegate = self
        blockTextField.delegate = self
        streetTextField.delegate = self

        buildingNumberTextField.keyboardType = .numberPad
        blockTextField.keyboardType = .numberPad
        streetTextField.keyboardType = .numberPad

        serviceAreaTextField.returnKeyType = .next
        buildingNumberTextField.returnKeyType = .next
        blockTextField.returnKeyType = .next
        streetTextField.returnKeyType = .done
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == serviceAreaTextField {
            buildingNumberTextField.becomeFirstResponder()
        } else if textField == buildingNumberTextField {
            blockTextField.becomeFirstResponder()
        } else if textField == blockTextField {
            streetTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    private func setupServiceAreaDropdown() {
        serviceAreaPicker.dataSource = self
        serviceAreaPicker.delegate = self
        serviceAreaTextField.inputView = serviceAreaPicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePickingArea))
        let space = UIBarButtonItem(systemItem: .flexibleSpace)
        toolbar.setItems([space, done], animated: false)
        serviceAreaTextField.inputAccessoryView = toolbar
    }

    @objc private func donePickingArea() {
        if (serviceAreaTextField.text ?? "").isEmpty {
            serviceAreaTextField.text = serviceAreas.first
        }
        view.endEditing(true)
    }

    private func setupDismissKeyboardTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func showAlert(title: String, message: String, onOK: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in onOK?() })
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
            vc.donorId = Auth.auth().currentUser?.uid
            vc.donationId = self.createdDonationId
        }
    }

}

extension ConfirmLocationViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { serviceAreas.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { serviceAreas[row] }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        serviceAreaTextField.text = serviceAreas[row]
    }
}
