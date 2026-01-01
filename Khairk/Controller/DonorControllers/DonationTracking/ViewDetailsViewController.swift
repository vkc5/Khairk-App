//
//  ViewDetailsViewController.swift
//  Khairk
//
//  Created by FM on 19/12/2025.
//


import UIKit

final class ViewDetailsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var donationImageView: UIImageView!
    @IBOutlet private weak var foodNameLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var expiryDateLabel: UILabel!
    @IBOutlet private weak var pickupDeliveryLabel: UILabel!

    // Delivery labels
    @IBOutlet private weak var serviceAreaLabel: UILabel!
    @IBOutlet private weak var streetLabel: UILabel!
    @IBOutlet private weak var blockLabel: UILabel!
    @IBOutlet private weak var buildingNumberLabel: UILabel!

    // Pickup label
    @IBOutlet private weak var pickupTimeLabel: UILabel!

    @IBOutlet private weak var cancelButton: UIButton!

    // MARK: - Data
    var item: DonationTrackingViewController.DonationItem?
    private var currentImageURL: String?

    // MARK: - Styling
    private let labelFont = UIFont.systemFont(ofSize: 17, weight: .regular)
    private let titleFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
    private let titleColor = UIColor.black
    private let valueColor = UIColor.secondaryLabel   // gray

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "View Details"
        view.backgroundColor = .white

        setupUI()
        render()
    }

    // MARK: - UI
    private func setupUI() {
        donationImageView.contentMode = .scaleAspectFill
        donationImageView.clipsToBounds = true
        donationImageView.layer.cornerRadius = 16

        cancelButton.setTitle("Cancel Donation", for: .normal)
        cancelButton.backgroundColor = .systemRed
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelButton.layer.cornerRadius = 14
        cancelButton.clipsToBounds = true

        // Keep labels single line (change to 0 if you want wrapping)
        [quantityLabel, expiryDateLabel, pickupDeliveryLabel,
         serviceAreaLabel, streetLabel, blockLabel, buildingNumberLabel, pickupTimeLabel].forEach {
            $0?.numberOfLines = 1
        }
    }

    private func render() {
        guard let item else { return }

        // Basic info
        foodNameLabel.text = item.foodName
        descriptionLabel.text = (item.note?.isEmpty == false) ? item.note : "—"

        quantityLabel.attributedText = makeKeyValueText(key: "Quantity", value: "\(item.quantity)")

        if let expiry = item.expiryDate {
            expiryDateLabel.attributedText = makeKeyValueText(key: "Expiry Date", value: formatDate(expiry))
        } else {
            expiryDateLabel.attributedText = makeKeyValueText(key: "Expiry Date", value: "—")
        }

        let type = (item.donationType ?? "pickup").lowercased()
        pickupDeliveryLabel.attributedText = makeKeyValueText(key: "Option", value: type.capitalized)

        loadImage(from: item.imageURL)

        // ✅ Cancel allowed when status is pending OR accepted
        let canCancel = (item.status == .pending || item.status == .accepted)
        cancelButton.isHidden = !canCancel

        // Hide all extra fields first
        serviceAreaLabel.isHidden = true
        streetLabel.isHidden = true
        blockLabel.isHidden = true
        buildingNumberLabel.isHidden = true
        pickupTimeLabel.isHidden = true

        // Show section based on type
        if type == "delivery" {
            serviceAreaLabel.isHidden = false
            streetLabel.isHidden = false
            blockLabel.isHidden = false
            buildingNumberLabel.isHidden = false

            serviceAreaLabel.attributedText = makeKeyValueText(key: "Service Area", value: item.serviceArea ?? "—")
            streetLabel.attributedText = makeKeyValueText(key: "Street", value: item.street ?? "—")
            blockLabel.attributedText = makeKeyValueText(key: "Block", value: item.block ?? "—")
            buildingNumberLabel.attributedText = makeKeyValueText(key: "Building No", value: item.buildingNumber ?? "—")

        } else {
            pickupTimeLabel.isHidden = false

            if let t = item.pickupTime {
                pickupTimeLabel.attributedText = makeKeyValueText(key: "Pickup Time", value: formatDateTime(t))
            } else {
                pickupTimeLabel.attributedText = makeKeyValueText(key: "Pickup Time", value: "—")
            }
        }
    }

    // MARK: - Key/Value styling (Bold key + black, gray value)
    private func makeKeyValueText(key: String, value: String) -> NSAttributedString {
        let result = NSMutableAttributedString(
            string: "\(key): ",
            attributes: [
                .font: titleFont,
                .foregroundColor: titleColor
            ]
        )

        result.append(NSAttributedString(
            string: value,
            attributes: [
                .font: labelFont,
                .foregroundColor: valueColor
            ]
        ))

        return result
    }

    private func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: date)
    }

    private func formatDateTime(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: date)
    }

    private func loadImage(from urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else {
            donationImageView.image = UIImage(systemName: "photo")
            currentImageURL = nil
            return
        }

        currentImageURL = urlString
        donationImageView.image = UIImage(systemName: "photo")

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            guard let data, let img = UIImage(data: data) else { return }
            guard self.currentImageURL == urlString else { return }

            DispatchQueue.main.async {
                self.donationImageView.image = img
            }
        }.resume()
    }

    // MARK: - Actions
    @IBAction private func cancelTapped(_ sender: UIButton) {
        guard let item else { return }

        // ✅ Block cancel after collected/delivered
        if item.status == .collected || item.status == .delivered {
            showAlert(title: "Not Allowed", message: "You can't cancel after it is collected or delivered.")
            return
        }

        // ✅ Allowed for pending/accepted (Firebase connection later)
        showAlert(title: "Coming Soon", message: "Cancel will be connected to Firebase later.")
    }

    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
