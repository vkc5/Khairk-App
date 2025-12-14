//
//  EditProfileViewController.swift
//  Khairk
//
//  Created by vkc5 on 04/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CollectorEditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIImageView!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var serviceAreaButton: UIButton!

    @IBOutlet weak var saveButton: UIButton!
    
    private let db = Firestore.firestore()

    private var selectedAvatarImage: UIImage?
    private var currentProfileImageUrl: String?
    private var selectedServiceArea: String?

    enum Mode {
        case view
        case edit
    }

    private var mode: Mode = .view

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI(for: .view)       // start in view mode
        cameraButton.layer.cornerRadius = 24
        cameraButton.clipsToBounds = true
        setupAvatarUI()
        setupCameraTap()
        setupServiceAreaDropdown()
        loadCurrentProfile()
        // Do any additional setup after loading the view.
    }
    
    func setupServiceAreaDropdown() {
        let areas = ["Manama", "Riffa", "Muharraq", "Isa Town", "Hamad Town"]

        serviceAreaButton.setTitle("Select Service Area", for: .normal)
        selectedServiceArea = nil

        let actions = areas.map { area in
            UIAction(title: area) { [weak self] _ in
                self?.serviceAreaButton.setTitle(area, for: .normal)
                self?.selectedServiceArea = area
            }
        }

        serviceAreaButton.menu = UIMenu(title: "", children: actions)
        serviceAreaButton.showsMenuAsPrimaryAction = true
    }
    func setupUI() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
    }
    
    @objc func editTapped() {
        updateUI(for: .edit)
    }

    @objc func cancelTapped() {
        updateUI(for: .view)
    }

    func updateUI(for newMode: Mode) {
        mode = newMode

        let isEditing = (newMode == .edit)

        // Text fields editable or not
        [nameTextField, phoneTextField, serviceAreaButton].forEach {
            $0?.isUserInteractionEnabled = isEditing
        }

        // Show/hide Save button
        saveButton.isHidden = !isEditing

        // Show/hide camera icon
        cameraButton.isHidden = !isEditing

        // Nav bar buttons
        if isEditing {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Cancel",
                style: .plain,
                target: self,
                action: #selector(cancelTapped)
            )
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit",
                style: .plain,
                target: self,
                action: #selector(editTapped)
            )
        }
    }
    
    private func setupAvatarUI() {
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill

        // Make it circular after layout
        DispatchQueue.main.async {
            self.avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.height / 2
        }
    }
    private func setupCameraTap() {
        cameraButton.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(pickAvatar))
        cameraButton.addGestureRecognizer(tap)
    }
    // MARK: - Load current data

    private func loadCurrentProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).getDocument { [weak self] snap, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Load profile error:", error.localizedDescription)
                    return
                }

                let data = snap?.data() ?? [:]

                let name = data["name"] as? String ?? ""
                let email = data["email"] as? String ?? (Auth.auth().currentUser?.email ?? "")
                let phone = data["phone"] as? String ?? ""
                let serviceArea = data["serviceArea"] as? String
                let imageUrl = data["profileImageUrl"] as? String

                self?.nameTextField.text = name
                self?.emailTextField.text = email
                self?.phoneTextField.text = phone
                
                if let area = serviceArea, !area.isEmpty {
                    self?.selectedServiceArea = area
                    self?.serviceAreaButton.setTitle(area, for: .normal)
                } else {
                    self?.selectedServiceArea = nil
                    self?.serviceAreaButton.setTitle("Select Service Area", for: .normal)
                }
                // Usually email should not be editable (matches most apps)
                self?.emailTextField.isUserInteractionEnabled = false
                self?.emailTextField.textColor = .secondaryLabel

                self?.currentProfileImageUrl = imageUrl

                if let imageUrl = imageUrl {
                    self?.loadImage(from: imageUrl)
                } else {
                    self?.avatarImageView.image = UIImage(systemName: "person.circle.fill")
                }
            }
        }
    }

    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.avatarImageView.image = image
            }
        }.resume()
    }

    // MARK: - Pick avatar

    @objc private func pickAvatar() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }
        selectedAvatarImage = image
        avatarImageView.image = image
    }

    // MARK: - Save

    @IBAction func saveTapped(_ sender: UIButton) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let name = (nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = (phoneTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let area = selectedServiceArea, !area.isEmpty else {
            showAlert(title: "Missing Info", message: "Please select a service area.")
            return
        }
        guard !name.isEmpty, !phone.isEmpty else {
            showAlert(title: "Missing Info", message: "Please enter your name and phone number.")
            return
        }

        // If user selected a new image -> upload to Cloudinary first, then update Firestore
        if let newImage = selectedAvatarImage {
            saveButton.isEnabled = false

            CloudinaryService.shared.uploadImage(newImage) { [weak self] result in
                DispatchQueue.main.async {
                    self?.saveButton.isEnabled = true

                    switch result {
                    case .success(let url):
                        self?.updateUser(uid: uid, name: name, phone: phone, serviceArea: area, profileImageUrl: url)

                    case .failure(let error):
                        self?.showAlert(title: "Upload Failed", message: error.localizedDescription)
                    }
                }
            }
        } else {
            // No new image -> just update text fields
            updateUser(uid: uid, name: name, phone: phone, serviceArea: area, profileImageUrl: currentProfileImageUrl)
        }
    }

    private func updateUser(uid: String, name: String, phone: String, serviceArea: String, profileImageUrl: String?) {
        var updateData: [String: Any] = [
            "name": name,
            "phone": phone,
            "serviceArea": serviceArea
        ]

        if let profileImageUrl = profileImageUrl {
            updateData["profileImageUrl"] = profileImageUrl
        }

        db.collection("users").document(uid).updateData(updateData) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(title: "Save Failed", message: error.localizedDescription)
                    return
                }

                self?.showAlert(title: "Saved", message: "Your profile has been updated.") {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
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
