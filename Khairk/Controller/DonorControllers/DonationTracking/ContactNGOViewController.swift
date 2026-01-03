//
//  ContactNGOViewController.swift
//  Khairk
//
//  Created by FM on 02/01/2026.
//

import UIKit
import FirebaseFirestore

final class ContactNGOViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var whatsappButton: UIButton!
    @IBOutlet private weak var callButton: UIButton!

    // MARK: - Input
    var caseId: String = ""

    // MARK: - Private
    private let db = Firestore.firestore()
    private var phoneNumber: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Debug: confirm what arrives to this screen
        print("📌 ContactNGO received caseId = [\(caseId)]")

        fetchCase()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoImageView.layer.cornerRadius = logoImageView.bounds.width / 2
        logoImageView.clipsToBounds = true
    }

    private func setupUI() {
        title = "Contact NGO"

        whatsappButton.layer.cornerRadius = 10
        callButton.layer.cornerRadius = 10

        statusLabel.text = "Loading..."
        nameLabel.text = "NGO"

        whatsappButton.isEnabled = false
        callButton.isEnabled = false

        logoImageView.image = UIImage(named: "placeholder")
    }

    private func fetchCase() {
        // IMPORTANT: Trim spaces/newlines (fixes "NGO not found" when ID has whitespace)
        let trimmedCaseId = caseId.trimmingCharacters(in: .whitespacesAndNewlines)

        print("📌 ContactNGO using trimmedCaseId = [\(trimmedCaseId)]")

        guard !trimmedCaseId.isEmpty else {
            statusLabel.text = "Missing case"
            return
        }

        db.collection("ngoCases").document(trimmedCaseId).getDocument { [weak self] snap, error in
            guard let self = self else { return }

            if let error = error {
                print("Firestore getDocument error:", error)
                DispatchQueue.main.async {
                    self.statusLabel.text = "Failed to load NGO"
                    self.whatsappButton.isEnabled = false
                    self.callButton.isEnabled = false
                }
                return
            }

            guard let snap = snap else {
                print("Snapshot is nil")
                DispatchQueue.main.async {
                    self.statusLabel.text = "Failed to load NGO"
                }
                return
            }

            print("ngoCases doc exists? ->", snap.exists, "docID:", snap.documentID)

            guard let data = snap.data() else {
                DispatchQueue.main.async {
                    self.statusLabel.text = "NGO not found"
                    self.whatsappButton.isEnabled = false
                    self.callButton.isEnabled = false
                }
                print("Document not found in ngoCases for caseId:", trimmedCaseId)
                return
            }

            print("ngoCases doc data:", data)

            let ngoName = (data["name"] as? String) ?? (data["ngoName"] as? String) ?? "NGO"

            // NOTE: If you don't store phoneNumber in ngoCases, it will stay empty.
            let phone = (data["phoneNumber"] as? String) ?? ""

            DispatchQueue.main.async {
                self.nameLabel.text = ngoName
                self.phoneNumber = phone

                let hasPhone = !phone.isEmpty

                if hasPhone {
                    self.statusLabel.text = "Available to contact"
                    self.whatsappButton.isHidden = false
                    self.callButton.isHidden = false
                } else {
                    self.statusLabel.text = "This NGO will contact you once your donation is accepted."
                    self.whatsappButton.isHidden = true
                    self.callButton.isHidden = true
                }

            }

            if let imageURL = data["imageURL"] as? String, !imageURL.isEmpty {
                self.loadImage(from: imageURL)
            }
        }
    }

    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data else { return }
            DispatchQueue.main.async {
                self.logoImageView.image = UIImage(data: data)
            }
        }.resume()
    }

    @IBAction private func callTapped(_ sender: UIButton) {
        guard !phoneNumber.isEmpty else { return }
        let cleaned = phoneNumber.filter { "0123456789+".contains($0) }

        guard let url = URL(string: "tel://\(cleaned)"),
              UIApplication.shared.canOpenURL(url) else {
            statusLabel.text = "Call not available"
            return
        }
        UIApplication.shared.open(url)
    }

    @IBAction private func whatsappTapped(_ sender: UIButton) {
        guard !phoneNumber.isEmpty else { return }
        let digits = phoneNumber.filter { "0123456789".contains($0) }

        guard let url = URL(string: "https://wa.me/\(digits)") else { return }
        UIApplication.shared.open(url)
    }
}
