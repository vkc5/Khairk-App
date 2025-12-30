//
//  AddNewGoalViewController.swift
//  Khairk
//
//  Created by vkc5 on 18/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AddNewGoalViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var uploadImageView: UIImageView!   // or your image placeholder
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var targetSlider: UISlider!
    @IBOutlet weak var addNewGoalButton: UIButton!

    // Optional: if you have a label to show slider value
    @IBOutlet weak var targetValueLabel: UILabel?      // optional

    private let db = Firestore.firestore()
    private var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    private func setupUI() {
        // Date pickers
        startDatePicker.minimumDate = Date()
        endDatePicker.minimumDate = startDatePicker.date

        // Update end picker when start changes
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)

        // Slider
        updateTargetLabel()

        targetSlider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        // Tap image to pick
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickImage)))
    }
    
    @objc private func startDateChanged() {
        // Ensure end >= start
        endDatePicker.minimumDate = startDatePicker.date
        if endDatePicker.date < startDatePicker.date {
            endDatePicker.date = startDatePicker.date
        }
    }

    @objc private func sliderChanged() {
        updateTargetLabel()
    }

    private func updateTargetLabel() {
        let target = Int(targetSlider.value)
        targetValueLabel?.text = "\(target) Meals" // change BD to your currency if needed
    }

    // MARK: - Image picker
    @objc private func pickImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let img = info[.originalImage] as? UIImage else { return }
        selectedImage = img
        uploadImageView.image = img
        uploadImageView.contentMode = .scaleAspectFill
        uploadImageView.clipsToBounds = true
    }

    // MARK: - Save Goal
    @IBAction func addNewGoalTapped(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else {
            showAlert("Error", "You are not logged in.")
            return
        }

        let start = startDatePicker.date
        let end = endDatePicker.date

        guard end >= start else {
            showAlert("Invalid Dates", "End date must be after start date.")
            return
        }

        let targetAmount = Int(targetSlider.value)
        guard targetAmount > 0 else {
            showAlert("Invalid Target", "Please choose a target amount.")
            return
        }

        addNewGoalButton.isEnabled = false

        // 1) Upload image if exists
        if let img = selectedImage {
            CloudinaryService.shared.uploadImage(img) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let url):
                        self.saveGoal(uid: uid, start: start, end: end, target: targetAmount, imageUrl: url)
                    case .failure(let error):
                        self.addNewGoalButton.isEnabled = true
                        self.showAlert("Upload Failed", error.localizedDescription)
                    }
                }
            }
        } else {
            // Save without image
            saveGoal(uid: uid, start: start, end: end, target: targetAmount, imageUrl: nil)
        }
    }

    private func saveGoal(uid: String,
                          start: Date,
                          end: Date,
                          target: Int,
                          imageUrl: String?) {

        let goalRef = db.collection("users").document(uid).collection("goals").document()

        var data: [String: Any] = [
            "startDate": Timestamp(date: start),
            "endDate": Timestamp(date: end),
            "targetAmount": target,
            "status": "active",
            "createdAt": FieldValue.serverTimestamp()
        ]

        if let imageUrl = imageUrl {
            data["imageUrl"] = imageUrl
        }

        goalRef.setData(data) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.addNewGoalButton.isEnabled = true

                if let error = error {
                    self.showAlert("Error", error.localizedDescription)
                    return
                }

                self.showAlert("Success", "Goal created successfully ✅") {
                    self.dismiss(animated: true)
                }
            }
        }
    }

    // MARK: - Alert helper
    private func showAlert(_ title: String, _ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        present(alert, animated: true)
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
