//
//  CompleteNGODetailsViewController.swift
//  Khairk
//
//  Created by vkc5 on 26/11/2025.
//

import UIKit

class CompleteNGODetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var signupData: CollectorSignupData?
    
    @IBOutlet weak var logoImageView: UIImageView!        // preview for logo
    @IBOutlet weak var licenseImageView: UIImageView!     // preview for license

    @IBOutlet weak var memberNameTextField: UITextField!
    @IBOutlet weak var memberEmailTextField: UITextField!
    @IBOutlet weak var memberPhoneTextField: UITextField!

    @IBOutlet weak var serviceAreaButton: UIButton!
    
    // MARK: - Internal state

    private var selectedLogoImage: UIImage?
    private var selectedLicenseImage: UIImage?
    private var selectedServiceArea: String?

    private var isPickingLogo = true

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Complete NGO Details"
        setupServiceAreaDropdown()
        
        if let data = signupData {
            print("🟢 Got signup data from previous page:")
            print("   NGO Name: \(data.ngoName)")
            print("   Email:    \(data.email)")
            print("   Phone:    \(data.phone)")
            // You can also pre-fill some fields using this data if you want
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
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

    @IBAction func pickLogoTapped(_ sender: Any) {
        isPickingLogo = true
        presentImagePicker()
    }

    @IBAction func pickLicenseTapped(_ sender: Any) {
        isPickingLogo = false
        presentImagePicker()
    }

    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }

        if isPickingLogo {
            selectedLogoImage = image
            logoImageView.image = image
            logoImageView.contentMode = .scaleAspectFill
            logoImageView.clipsToBounds = true
        } else {
            selectedLicenseImage = image
            licenseImageView.image = image
            licenseImageView.contentMode = .scaleAspectFill
            licenseImageView.clipsToBounds = true
        }
    }

    // MARK: - Submit button (“Sign in”)

    @IBAction func submitApplicationTapped(_ sender: UIButton) {
        guard let signupData = signupData else {
            showAlert(title: "Error", message: "Missing basic signup data.")
            return
        }

        guard let serviceArea = selectedServiceArea else {
            showAlert(title: "Missing Info", message: "Please select a service area.")
            return
        }

        let memberName = (memberNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let memberEmail = (memberEmailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let memberPhone = (memberPhoneTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !memberName.isEmpty,
              !memberEmail.isEmpty,
              !memberPhone.isEmpty else {
            showAlert(title: "Missing Info", message: "Please fill all member information fields.")
            return
        }

        uploadAssetsAndCreateUser(
            signupData: signupData,
            serviceArea: serviceArea,
            memberName: memberName,
            memberEmail: memberEmail,
            memberPhone: memberPhone
        )
    }

    // MARK: - Upload + create user

    private func uploadAssetsAndCreateUser(
        signupData: CollectorSignupData,
        serviceArea: String,
        memberName: String,
        memberEmail: String,
        memberPhone: String
    ) {
        var logoUrl: String?
        var licenseUrl: String?

        let group = DispatchGroup()

        if let logoImage = selectedLogoImage {
            group.enter()
            CloudinaryService.shared.uploadImage(logoImage) { result in
                switch result {
                case .success(let url):
                    print("✅ Logo uploaded: \(url)")
                    logoUrl = url
                case .failure(let error):
                    print("❌ Logo upload failed:", error.localizedDescription)
                }
                group.leave()
            }
        }

        if let licenseImage = selectedLicenseImage {
            group.enter()
            CloudinaryService.shared.uploadImage(licenseImage) { result in
                switch result {
                case .success(let url):
                    print("✅ License uploaded: \(url)")
                    licenseUrl = url
                case .failure(let error):
                    print("❌ License upload failed:", error.localizedDescription)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            let extra = NGOExtraDetails(
                serviceArea: serviceArea,
                memberName: memberName,
                memberEmail: memberEmail,
                memberPhone: memberPhone,
                logoUrl: logoUrl,
                licenseUrl: licenseUrl
            )

            AuthService.shared.createCollector(
                signupData: signupData,
                extraDetails: extra
            ) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let user):
                        print("🎉 Collector created: \(user.email)")
                        self?.showAlert(
                            title: "Application Submitted",
                            message: "Your organization has been registered."
                        ) {
                            // for now go back to login
                            self?.navigationController?.popToRootViewController(animated: true)
                        }

                    case .failure(let error):
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
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
