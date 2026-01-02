import UIKit
import FirebaseFirestore

final class CaseDetailsViewController: UIViewController {

    var caseId: String = ""

    private let service = CaseService()
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let caseImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let detailsTitleLabel = UILabel()
    private let detailsLabel = UILabel()
    private let progressTitleLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let progressLabel = UILabel()
    private let deleteButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Case Details"
        view.backgroundColor = .systemBackground

        setupLayout()
        startListening()
    }

    deinit {
        listener?.remove()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        caseImageView.translatesAutoresizingMaskIntoConstraints = false
        caseImageView.contentMode = .scaleAspectFill
        caseImageView.clipsToBounds = true
        caseImageView.layer.cornerRadius = 14
        caseImageView.image = UIImage(named: "ImagePicker") ?? UIImage(systemName: "photo")

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 0

        detailsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        detailsTitleLabel.textColor = .secondaryLabel
        detailsTitleLabel.text = "Details"

        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.font = UIFont.systemFont(ofSize: 13)
        detailsLabel.textColor = .secondaryLabel
        detailsLabel.numberOfLines = 0

        progressTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        progressTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        progressTitleLabel.textColor = .secondaryLabel
        progressTitleLabel.text = "Progress Tracker"

        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = UIColor.systemGray5
        progressView.progressTintColor = UIColor(named: "MainBrand-500") ?? UIColor.systemGreen
        progressView.layer.cornerRadius = 6
        progressView.clipsToBounds = true

        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        progressLabel.textColor = .label

        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setTitle("Delete Case", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = UIColor.systemRed
        deleteButton.layer.cornerRadius = 16
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [
            caseImageView,
            titleLabel,
            descriptionLabel,
            detailsTitleLabel,
            detailsLabel,
            progressTitleLabel,
            progressView,
            progressLabel,
            deleteButton,
        ].forEach { contentView.addSubview($0) }

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

            caseImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            caseImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            caseImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            caseImageView.heightAnchor.constraint(equalToConstant: 180),

            titleLabel.topAnchor.constraint(equalTo: caseImageView.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            detailsTitleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 12),
            detailsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            detailsLabel.topAnchor.constraint(equalTo: detailsTitleLabel.bottomAnchor, constant: 6),
            detailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            progressTitleLabel.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor, constant: 16),
            progressTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            progressTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            progressView.topAnchor.constraint(equalTo: progressTitleLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            progressView.heightAnchor.constraint(equalToConstant: 8),

            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 8),
            progressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            deleteButton.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 20),
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.heightAnchor.constraint(equalToConstant: 48),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
        ])
    }

    private func startListening() {
        guard !caseId.isEmpty else {
            showAlert(title: "Missing Data", message: "Cannot load case details.")
            return
        }

        listener = db.collection("ngoCases")
            .document(caseId)
            .addSnapshotListener { [weak self] doc, err in
                guard let self = self else { return }
                if let err = err {
                    self.showAlert(title: "Error", message: err.localizedDescription)
                    return
                }
                guard let doc = doc, let item = NgoCase(doc: doc) else { return }
                self.render(item)
            }
    }

    private func render(_ item: NgoCase) {
        titleLabel.text = item.title
        descriptionLabel.text = item.details

        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        var detailLines: [String] = [
            "Measurements: \(item.measurements)",
            "Goal: \(item.goal)",
            "Start Date: \(formatter.string(from: item.startDate))",
            "End Date: \(formatter.string(from: item.endDate))",
        ]

        if !item.status.isEmpty {
            detailLines.append("Status: \(item.status)")
        }

        if !item.ngoName.isEmpty {
            detailLines.append("NGO: \(item.ngoName)")
        }

        detailsLabel.text = detailLines.joined(separator: "\n")

        let goalSafe = max(item.goal, 1)
        let progress = min(Float(item.collected) / Float(goalSafe), 1)
        progressView.setProgress(progress, animated: true)
        progressLabel.text = "\(item.collected) / \(item.goal)"
    }

    @objc private func deleteTapped() {
        guard !caseId.isEmpty else { return }

        let confirm = UIAlertController(
            title: "Delete Case",
            message: "Are you sure you want to delete this case?",
            preferredStyle: .alert
        )
        confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirm.addAction(UIAlertAction(title: "Yes, Delete Case", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.service.deleteCase(caseId: self.caseId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let err):
                        self.showAlert(title: "Delete Failed", message: err.localizedDescription)
                    }
                }
            }
        })
        present(confirm, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
