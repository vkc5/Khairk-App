import UIKit
import FirebaseFirestore

final class NGOPickupDetailsViewController: UIViewController {

    var donationId: String = ""

    private let service = DonationService.shared
    private var listener: ListenerRegistration?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let headerImageView = UIImageView()
    private let titleLabel = UILabel()
    private let bannerView = UIView()
    private let bannerLabel = UILabel()

    private let foodDetailsTitle = UILabel()
    private let foodDetailsLabel = UILabel()

    private let donorDetailsTitle = UILabel()
    private let donorCard = UIView()
    private let donorNameLabel = UILabel()
    private let donorInfoLabel = UILabel()

    private let caseDetailsTitle = UILabel()
    private let caseCard = UIView()
    private let caseTitleLabel = UILabel()
    private let caseDetailsLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pickup Details"
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

        foodDetailsTitle.translatesAutoresizingMaskIntoConstraints = false
        foodDetailsTitle.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        foodDetailsTitle.textColor = .secondaryLabel
        foodDetailsTitle.text = "Food Details"

        foodDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
        foodDetailsLabel.font = UIFont.systemFont(ofSize: 13)
        foodDetailsLabel.textColor = .secondaryLabel
        foodDetailsLabel.numberOfLines = 0

        donorDetailsTitle.translatesAutoresizingMaskIntoConstraints = false
        donorDetailsTitle.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        donorDetailsTitle.textColor = .secondaryLabel
        donorDetailsTitle.text = "Donor Details"

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

        caseDetailsTitle.translatesAutoresizingMaskIntoConstraints = false
        caseDetailsTitle.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        caseDetailsTitle.textColor = .secondaryLabel
        caseDetailsTitle.text = "NGO Case Details"

        caseCard.translatesAutoresizingMaskIntoConstraints = false
        caseCard.backgroundColor = UIColor.systemGray6
        caseCard.layer.cornerRadius = 14

        caseTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        caseTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        caseTitleLabel.textColor = .label

        caseDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
        caseDetailsLabel.font = UIFont.systemFont(ofSize: 12)
        caseDetailsLabel.textColor = .secondaryLabel
        caseDetailsLabel.numberOfLines = 0

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [
            headerImageView,
            titleLabel,
            bannerView,
            foodDetailsTitle,
            foodDetailsLabel,
            donorDetailsTitle,
            donorCard,
            caseDetailsTitle,
            caseCard,
        ].forEach { contentView.addSubview($0) }

        bannerView.addSubview(bannerLabel)
        donorCard.addSubview(donorNameLabel)
        donorCard.addSubview(donorInfoLabel)
        caseCard.addSubview(caseTitleLabel)
        caseCard.addSubview(caseDetailsLabel)

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

            foodDetailsTitle.topAnchor.constraint(equalTo: bannerView.bottomAnchor, constant: 16),
            foodDetailsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            foodDetailsTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            foodDetailsLabel.topAnchor.constraint(equalTo: foodDetailsTitle.bottomAnchor, constant: 6),
            foodDetailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            foodDetailsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            donorDetailsTitle.topAnchor.constraint(equalTo: foodDetailsLabel.bottomAnchor, constant: 16),
            donorDetailsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            donorDetailsTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            donorCard.topAnchor.constraint(equalTo: donorDetailsTitle.bottomAnchor, constant: 8),
            donorCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            donorCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            donorNameLabel.topAnchor.constraint(equalTo: donorCard.topAnchor, constant: 12),
            donorNameLabel.leadingAnchor.constraint(equalTo: donorCard.leadingAnchor, constant: 12),
            donorNameLabel.trailingAnchor.constraint(equalTo: donorCard.trailingAnchor, constant: -12),

            donorInfoLabel.topAnchor.constraint(equalTo: donorNameLabel.bottomAnchor, constant: 4),
            donorInfoLabel.leadingAnchor.constraint(equalTo: donorCard.leadingAnchor, constant: 12),
            donorInfoLabel.trailingAnchor.constraint(equalTo: donorCard.trailingAnchor, constant: -12),
            donorInfoLabel.bottomAnchor.constraint(equalTo: donorCard.bottomAnchor, constant: -12),

            caseDetailsTitle.topAnchor.constraint(equalTo: donorCard.bottomAnchor, constant: 16),
            caseDetailsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            caseDetailsTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            caseCard.topAnchor.constraint(equalTo: caseDetailsTitle.bottomAnchor, constant: 8),
            caseCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            caseCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            caseCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            caseTitleLabel.topAnchor.constraint(equalTo: caseCard.topAnchor, constant: 12),
            caseTitleLabel.leadingAnchor.constraint(equalTo: caseCard.leadingAnchor, constant: 12),
            caseTitleLabel.trailingAnchor.constraint(equalTo: caseCard.trailingAnchor, constant: -12),

            caseDetailsLabel.topAnchor.constraint(equalTo: caseTitleLabel.bottomAnchor, constant: 4),
            caseDetailsLabel.leadingAnchor.constraint(equalTo: caseCard.leadingAnchor, constant: 12),
            caseDetailsLabel.trailingAnchor.constraint(equalTo: caseCard.trailingAnchor, constant: -12),
            caseDetailsLabel.bottomAnchor.constraint(equalTo: caseCard.bottomAnchor, constant: -12),
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
                self.render(donation)
            }
        }
    }

    private func render(_ donation: Donation) {

        // Title
        let foodTitle: String = {
            if !donation.foodName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return donation.foodName
            }
            return donation.foodType ?? "Food"
        }()
        titleLabel.text = foodTitle

        // Date formatting
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        // expiryDate is Date (NOT optional)
        let expiryText = formatter.string(from: donation.expiryDate)

        // Description (was "details" before)
        let desc = donation.description.trimmingCharacters(in: .whitespacesAndNewlines)
        let descText = desc.isEmpty ? "N/A" : desc

        // Pickup method is optional now
        let pickupText = donation.pickupMethod ?? "N/A"

        // Details label
        foodDetailsLabel.text = """
        Food Name: \(foodTitle)
        Quantity: \(donation.quantity)
        Expiry Date: \(expiryText)
        Description: \(descText)
        How to receive: \(pickupText)
        """

        // Donor info (optional now)
        donorNameLabel.text = donation.donorName ?? "Unknown"

        var donorInfo = ""
        if let email = donation.donorEmail, !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            donorInfo += "Email: \(email)\n"
        }
        if let phone = donation.donorPhone, !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            donorInfo += "Phone: \(phone)\n"
        }
        donorInfoLabel.text = donorInfo.isEmpty ? "Contact info not provided" : donorInfo

        // Case title (optional now)
        if let caseTitle = donation.caseTitle, !caseTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            caseTitleLabel.text = caseTitle
        } else {
            caseTitleLabel.text = "Case ID: \(donation.caseId)"
        }

        // Case description/target/collected (optional now)
        let caseDescText: String = {
            let cd = (donation.caseDescription ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return cd.isEmpty ? "No description" : cd
        }()

        let target = donation.caseTarget ?? 0
        let collected = donation.caseCollected ?? 0

        if target > 0 {
            caseDetailsLabel.text = """
            \(caseDescText)

            Collected: \(collected)
            Target: \(target)
            """
        } else {
            caseDetailsLabel.text = caseDescText
        }

        // Expiry banner (expiryDate is Date, so no if-let)
        let days = Calendar.current.dateComponents([.day], from: Date(), to: donation.expiryDate).day ?? 0
        if days <= 2 {
            bannerView.isHidden = false
            bannerLabel.text = "Expires Soon\nFood expires in \(max(days, 0)) days - \(expiryText)"
        } else {
            bannerView.isHidden = true
        }
    }


    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
