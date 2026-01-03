import UIKit
import FirebaseFirestore

final class NGODonationDetailsViewController: UIViewController {

    var donationId: String = ""

    private let service = DonationService.shared
    private var listener: ListenerRegistration?
    private var currentDonation: Donation?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerImageView = UIImageView()
    private let titleLabel = UILabel()
    private let bannerView = UIView()
    private let bannerLabel = UILabel()

    private let foodTitleLabel = UILabel()
    private let foodDetailsLabel = UILabel()

    private let donorTitleLabel = UILabel()
    private let donorCard = UIView()
    private let donorNameLabel = UILabel()
    private let donorInfoLabel = UILabel()

    private let actionStack = UIStackView()
    private let approveButton = UIButton(type: .system)
    private let rejectButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Donation Details"
        view.backgroundColor = .systemBackground
        setupLayout()
        listen()
    }

    deinit {
        listener?.remove()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        headerImageView.layer.cornerRadius = 14
        headerImageView.image = UIImage(named: "ImagePicker") ?? UIImage(systemName: "photo")

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label

        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        bannerView.layer.cornerRadius = 10
        bannerView.isHidden = true

        bannerLabel.translatesAutoresizingMaskIntoConstraints = false
        bannerLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        bannerLabel.textColor = .systemRed
        bannerLabel.numberOfLines = 0

        foodTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        foodTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        foodTitleLabel.textColor = .secondaryLabel
        foodTitleLabel.text = "Food Details"

        foodDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
        foodDetailsLabel.font = UIFont.systemFont(ofSize: 13)
        foodDetailsLabel.textColor = .secondaryLabel
        foodDetailsLabel.numberOfLines = 0

        donorTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        donorTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        donorTitleLabel.textColor = .secondaryLabel
        donorTitleLabel.text = "Donor Details"

        donorCard.translatesAutoresizingMaskIntoConstraints = false
        donorCard.backgroundColor = UIColor.systemGray6
        donorCard.layer.cornerRadius = 14

        donorNameLabel.translatesAutoresizingMaskIntoConstraints = false
        donorNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        donorNameLabel.textColor = .label

        donorInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        donorInfoLabel.font = UIFont.systemFont(ofSize: 12)
        donorInfoLabel.textColor = .secondaryLabel
        donorInfoLabel.numberOfLines = 0

        actionStack.translatesAutoresizingMaskIntoConstraints = false
        actionStack.axis = .horizontal
        actionStack.spacing = 12
        actionStack.distribution = .fillEqually

        approveButton.setTitle("Accept", for: .normal)
        approveButton.setTitleColor(.white, for: .normal)
        approveButton.backgroundColor = UIColor(named: "MainBrand-500") ?? UIColor.systemGreen
        approveButton.layer.cornerRadius = 16
        approveButton.addTarget(self, action: #selector(approveTapped), for: .touchUpInside)

        rejectButton.setTitle("Reject", for: .normal)
        rejectButton.setTitleColor(.white, for: .normal)
        rejectButton.backgroundColor = UIColor.systemRed
        rejectButton.layer.cornerRadius = 16
        rejectButton.addTarget(self, action: #selector(rejectTapped), for: .touchUpInside)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [
            headerImageView,
            titleLabel,
            bannerView,
            foodTitleLabel,
            foodDetailsLabel,
            donorTitleLabel,
            donorCard,
            actionStack,
        ].forEach { contentView.addSubview($0) }

        bannerView.addSubview(bannerLabel)
        donorCard.addSubview(donorNameLabel)
        donorCard.addSubview(donorInfoLabel)
        actionStack.addArrangedSubview(approveButton)
        actionStack.addArrangedSubview(rejectButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            headerImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerImageView.heightAnchor.constraint(equalToConstant: 180),

            titleLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            bannerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            bannerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bannerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            bannerLabel.topAnchor.constraint(equalTo: bannerView.topAnchor, constant: 8),
            bannerLabel.leadingAnchor.constraint(equalTo: bannerView.leadingAnchor, constant: 10),
            bannerLabel.trailingAnchor.constraint(equalTo: bannerView.trailingAnchor, constant: -10),
            bannerLabel.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: -8),

            foodTitleLabel.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 16),
            foodTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            foodTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            foodDetailsLabel.topAnchor.constraint(equalTo: foodTitleLabel.bottomAnchor, constant: 6),
            foodDetailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            foodDetailsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            donorTitleLabel.topAnchor.constraint(equalTo: foodDetailsLabel.bottomAnchor, constant: 16),
            donorTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            donorTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            donorCard.topAnchor.constraint(equalTo: donorTitleLabel.bottomAnchor, constant: 8),
            donorCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            donorCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            donorNameLabel.topAnchor.constraint(equalTo: donorCard.topAnchor, constant: 12),
            donorNameLabel.leadingAnchor.constraint(equalTo: donorCard.leadingAnchor, constant: 12),
            donorNameLabel.trailingAnchor.constraint(equalTo: donorCard.trailingAnchor, constant: -12),

            donorInfoLabel.topAnchor.constraint(equalTo: donorNameLabel.bottomAnchor, constant: 4),
            donorInfoLabel.leadingAnchor.constraint(equalTo: donorCard.leadingAnchor, constant: 12),
            donorInfoLabel.trailingAnchor.constraint(equalTo: donorCard.trailingAnchor, constant: -12),
            donorInfoLabel.bottomAnchor.constraint(equalTo: donorCard.bottomAnchor, constant: -12),

            actionStack.topAnchor.constraint(equalTo: donorCard.bottomAnchor, constant: 24),
            actionStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            actionStack.heightAnchor.constraint(equalToConstant: 48),
            actionStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
        ])
    }

    private func listen() {
        guard !donationId.isEmpty else { return }
        listener = service.listenDonation(donationId: donationId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let err):
                self.showAlert(title: "Error", message: err.localizedDescription)
            case .success(let donation):
                self.currentDonation = donation
                self.render(donation)
            }
        }
    }

    private func render(_ donation: Donation) {

        // ---- Title ----
        let foodTitle: String = {
            if !donation.foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return donation.foodName
            }
            // fallback for collector data if foodName is empty
            return donation.foodType ?? "Food"
        }()

        titleLabel.text = foodTitle

        // ---- Expiry formatting ----
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let expiryText = formatter.string(from: donation.expiryDate)

        // ---- Expiry banner logic ----
        let expiryDate = donation.expiryDate
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0

        if days <= 2 {
            bannerView.isHidden = false
            bannerLabel.text = "Expires Soon\nFood expires in \(max(days, 0)) days - \(expiryText)"
        } else {
            bannerView.isHidden = true
        }

        // ---- Details block ----
        let pickupText = donation.pickupMethod ?? "N/A"

        let descriptionText: String = {
            let trimmed = donation.description.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? "N/A" : trimmed
        }()

        foodDetailsLabel.text = """
    Food Name: \(foodTitle)
    Quantity: \(donation.quantity)
    Expiry Date: \(expiryText)
    Description: \(descriptionText)
    How to receive: \(pickupText)
    """

        // ---- Donor info ----
        donorNameLabel.text = donation.donorName ?? "Unknown"

        var donorInfo = ""

        if let email = donation.donorEmail, !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            donorInfo += "Email: \(email)\n"
        }

        if let phone = donation.donorPhone, !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            donorInfo += "Phone: \(phone)\n"
        }

        donorInfoLabel.text = donorInfo.isEmpty ? "Contact info not provided" : donorInfo

        // ---- Buttons visibility ----
        let isPending = donation.status.lowercased() == "pending"
        approveButton.isHidden = !isPending
        rejectButton.isHidden = !isPending
        actionStack.isHidden = !isPending
    }


    @objc private func approveTapped() {
        guard let donation = currentDonation else { return }
        confirm(title: "Accept Donation", message: "Are you sure you want to accept this donation?", yesTitle: "Yes, Accept") { [weak self] in
            guard let self = self else { return }
            NGOContext.shared.getNgoId { result in
                switch result {
                case .failure(let err):
                    self.showAlert(title: "Error", message: err.localizedDescription)
                case .success(let ngoId):
                    self.service.approveDonation(
                        ngoId: ngoId,
                        donationId: donation.id,
                        caseId: donation.caseId,
                        quantity: donation.quantity
                    ) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                self.showAlert(title: "Donation Accepted", message: "The donation has been successfully accepted.")
                            case .failure(let err):
                                self.showAlert(title: "Accept Failed", message: err.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
    }

    @objc private func rejectTapped() {
        confirm(title: "Reject Donation", message: "Are you sure you want to reject this donation?", yesTitle: "Yes, Reject") { [weak self] in
            guard let self = self else { return }
            self.service.rejectDonation(donationId: self.donationId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.showAlert(title: "Donation Rejected", message: "The donation has been successfully rejected.")
                    case .failure(let err):
                        self.showAlert(title: "Reject Failed", message: err.localizedDescription)
                    }
                }
            }
        }
    }

    private func confirm(title: String, message: String, yesTitle: String, action: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: yesTitle, style: .default) { _ in action() })
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
