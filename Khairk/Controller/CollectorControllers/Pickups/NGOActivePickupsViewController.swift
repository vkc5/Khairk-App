import UIKit
import FirebaseFirestore

final class NGOActivePickupsViewController: UIViewController {

    private let service = DonationService.shared
    private var listener: ListenerRegistration?
    private var items: [Donation] = []
    private var filteredItems: [Donation] = []
    private var searchText: String = ""

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let headerView = UIView()
    private let searchBar = UISearchBar()
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Active Pickups"
        view.backgroundColor = .systemBackground

        setupNavigationBar()
        setupTableView()
        setupHeader()
        setupEmptyState()

        load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderLayout()
    }

    deinit {
        listener?.remove()
    }

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "MainBrand-500") ?? UIColor.systemGreen
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Requests",
            style: .plain,
            target: self,
            action: #selector(openRequests)
        )
    }

    @objc private func openRequests() {
        let vc = NGOAcceptsDonationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 260
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.register(NGOActivePickupCell.self, forCellReuseIdentifier: NGOActivePickupCell.reuseIdentifier)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupHeader() {
        headerView.backgroundColor = .systemBackground

        let headerStack = UIStackView()
        headerStack.axis = .vertical
        headerStack.spacing = 12
        headerStack.translatesAutoresizingMaskIntoConstraints = false

        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.searchTextField.backgroundColor = UIColor.systemGray6
        searchBar.searchTextField.layer.cornerRadius = 12
        searchBar.searchTextField.clipsToBounds = true

        headerStack.addArrangedSubview(searchBar)
        headerView.addSubview(headerStack)

        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            headerStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            headerStack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8),
        ])

        tableView.tableHeaderView = headerView
    }

    private func updateHeaderLayout() {
        let targetSize = CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let height = headerView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        if headerView.frame.size.height != height {
            headerView.frame.size.height = height
            tableView.tableHeaderView = headerView
        }
    }

    private func setupEmptyState() {
        emptyLabel.text = "No active pickups"
        emptyLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func load() {
        NGOContext.shared.getNgoId { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let err):
                self.showAlert(title: "Error", message: err.localizedDescription)
            case .success(let ngoId):
                self.listener = self.service.listenActivePickups(ngoId: ngoId) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let list):
                        self.items = list
                        self.applyFilters()
                    case .failure(let err):
                        self.showAlert(title: "Error", message: err.localizedDescription)
                    }
                }
            }
        }
    }

    private func applyFilters() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        filteredItems = items.filter { item in
            if query.isEmpty {
                return true
            }
            let foodType = item.foodType?.lowercased() ?? ""
            let donorName = item.donorName?.lowercased() ?? ""

            return item.foodName.lowercased().contains(query)
                || foodType.contains(query)
                || donorName.contains(query)
        }

        emptyLabel.isHidden = !filteredItems.isEmpty
        tableView.reloadData()
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func confirm(title: String, message: String, yesTitle: String, action: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: yesTitle, style: .default) { _ in action() })
        present(alert, animated: true)
    }
}

extension NGOActivePickupsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NGOActivePickupCell.reuseIdentifier,
            for: indexPath
        ) as? NGOActivePickupCell else {
            return UITableViewCell()
        }

        let donation = filteredItems[indexPath.row]
        cell.configure(with: donation)
        cell.onViewDetails = { [weak self] in
            let detailsVC = NGOPickupDetailsViewController()
            detailsVC.donationId = donation.id
            self?.navigationController?.pushViewController(detailsVC, animated: true)
        }
        cell.onMarkCollected = { [weak self] in
            self?.confirm(
                title: "Mark As Collected",
                message: "Mark this pickup as collected?",
                yesTitle: "Yes, Mark"
            ) {
                self?.service.markPickupCompleted(donationId: donation.id) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self?.showAlert(title: "Pickup Completed", message: "Pickup marked as collected.")
                        case .failure(let err):
                            self?.showAlert(title: "Update Failed", message: err.localizedDescription)
                        }
                    }
                }
            }
        }

        return cell
    }
}

extension NGOActivePickupsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        applyFilters()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

final class NGOActivePickupCell: UITableViewCell {

    static let reuseIdentifier = "NGOActivePickupCell"

    private let cardView = UIView()
    private let pickupImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let donorLabel = UILabel()
    private let badgeLabel = UILabel()
    private let buttonStack = UIStackView()
    private var imageTask: URLSessionDataTask?
    private var currentImageURL: String?
    private let markButton = UIButton(type: .system)
    private let detailsButton = UIButton(type: .system)

    var onMarkCollected: (() -> Void)?
    var onViewDetails: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        setupCard()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCard()
        setupLayout()
    }

    func configure(with donation: Donation) {
        let foodTitle = donation.foodName.isEmpty ? donation.foodType : donation.foodName
        titleLabel.text = foodTitle
        subtitleLabel.text = "\(donation.quantity) items"
        donorLabel.text = donation.donorName

        imageTask?.cancel()
        currentImageURL = donation.imageURL
        pickupImageView.image = UIImage(named: "ImagePicker") ?? UIImage(systemName: "photo")

        if !donation.imageURL.isEmpty, let url = URL(string: donation.imageURL) {
            imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self = self, let data = data else { return }
                if self.currentImageURL != donation.imageURL { return }
                DispatchQueue.main.async {
                    self.pickupImageView.image = UIImage(data: data)
                }
            }
            imageTask?.resume()
        }

        let badgeText = expiryBadgeText(for: donation.expiryDate)
        badgeLabel.text = badgeText
        badgeLabel.isHidden = badgeText.isEmpty
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        currentImageURL = nil
        pickupImageView.image = UIImage(named: "ImagePicker") ?? UIImage(systemName: "photo")
    }

    @objc private func markTapped() {
        onMarkCollected?()
    }

    @objc private func detailsTapped() {
        onViewDetails?()
    }

    private func expiryBadgeText(for date: Date?) -> String {
        guard let date = date else { return "" }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return days <= 2 ? "Expires Soon" : ""
    }

    private func setupCard() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)

        pickupImageView.translatesAutoresizingMaskIntoConstraints = false
        pickupImageView.contentMode = .scaleAspectFill
        pickupImageView.clipsToBounds = true
        pickupImageView.layer.cornerRadius = 12

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = .secondaryLabel

        donorLabel.translatesAutoresizingMaskIntoConstraints = false
        donorLabel.font = UIFont.systemFont(ofSize: 12)
        donorLabel.textColor = .secondaryLabel

        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        badgeLabel.textColor = UIColor.systemRed
        badgeLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 10
        badgeLabel.clipsToBounds = true

        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually

        markButton.setTitle("Mark As Collected", for: .normal)
        markButton.setTitleColor(.white, for: .normal)
        markButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        markButton.backgroundColor = UIColor(named: "MainBrand-500") ?? UIColor.systemGreen
        markButton.layer.cornerRadius = 12
        markButton.addTarget(self, action: #selector(markTapped), for: .touchUpInside)

        detailsButton.setTitle("View Details", for: .normal)
        detailsButton.setTitleColor(.white, for: .normal)
        detailsButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        detailsButton.backgroundColor = UIColor(named: "MainBrand-500") ?? UIColor.systemGreen
        detailsButton.layer.cornerRadius = 12
        detailsButton.addTarget(self, action: #selector(detailsTapped), for: .touchUpInside)

        contentView.addSubview(cardView)
        cardView.addSubview(pickupImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(donorLabel)
        cardView.addSubview(badgeLabel)
        cardView.addSubview(buttonStack)

        buttonStack.addArrangedSubview(markButton)
        buttonStack.addArrangedSubview(detailsButton)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            pickupImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            pickupImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            pickupImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            pickupImageView.heightAnchor.constraint(equalToConstant: 140),

            badgeLabel.topAnchor.constraint(equalTo: pickupImageView.bottomAnchor, constant: 8),
            badgeLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            badgeLabel.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.topAnchor.constraint(equalTo: pickupImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: badgeLabel.leadingAnchor, constant: -8),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            donorLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 4),
            donorLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            donorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            buttonStack.topAnchor.constraint(equalTo: donorLabel.bottomAnchor, constant: 12),
            buttonStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            buttonStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            buttonStack.heightAnchor.constraint(equalToConstant: 32),
            buttonStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
        ])
    }
}
