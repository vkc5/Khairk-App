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
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var whatsappButton: UIButton!
    @IBOutlet weak var callButton: UIButton!

    // MARK: - Input (passed from My Donation / Tracking)
    var caseId: String = ""

    // MARK: - Private properties
    private let db = Firestore.firestore()

    // Demo phone number (can be replaced later with real NGO contact)
    private let phoneNumber = "+97330000000"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchCase()
        
        logoImageView.image = UIImage(named: "placeholder")
    }

    // MARK: - UI Setup
    private func setupUI() {
        title = "Contact NGO"

        // Make the logo circular
        logoImageView.layer.cornerRadius = 70
        logoImageView.clipsToBounds = true

        // Style buttons
        whatsappButton.layer.cornerRadius = 10
        callButton.layer.cornerRadius = 10

        statusLabel.text = "Available to contact"
    }

    // MARK: - Firestore
    private func fetchCase() {
        guard !caseId.isEmpty else {
            print("❌ caseId is empty")
            return
        }

        db.collection("ngoCases").document(caseId).getDocument { [weak self] snap, _ in
            guard let self = self,
                  let data = snap?.data() else { return }

            // Read NGO name from ngoCases document
            self.nameLabel.text = data["name"] as? String ?? "NGO"

            // Load image if available
            if let imageURL = data["imageURL"] as? String {
                self.loadImage(from: imageURL)
            }
        }
    }

    // MARK: - Image loading
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.logoImageView.image = UIImage(data: data)
            }
        }.resume()
    }

    // MARK: - Actions
    @IBAction func callTapped(_ sender: UIButton) {
        let cleaned = phoneNumber.filter { "0123456789+".contains($0) }
        guard let url = URL(string: "tel://\(cleaned)"),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    @IBAction func whatsappTapped(_ sender: UIButton) {
        let digits = phoneNumber.filter { "0123456789".contains($0) }
        guard let url = URL(string: "https://wa.me/\(digits)") else { return }
        UIApplication.shared.open(url)
    }
}
