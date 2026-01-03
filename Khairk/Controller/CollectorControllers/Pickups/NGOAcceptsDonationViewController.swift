import UIKit
import FirebaseFirestore

final class NGOAcceptsDonationViewController: UIViewController {

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
        title = "Accepts donation"
        view.backgroundColor = .systemBackground

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

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 220
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.register(NGODonationRequestCell.self, forCellReuseIdentifier: NGODonationRequestCell.reuseIdentifier)

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
        emptyLabel.text = "No donation requests"
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
                self.listener = self.service.listenPendingDonations(ngoId: ngoId) { [weak self] result in
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
}

extension NGOAcceptsDonationViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NGODonationRequestCell.reuseIdentifier,
            for: indexPath
        ) as? NGODonationRequestCell else {
            return UITableViewCell()
        }

        cell.configure(with: filteredItems[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let donation = filteredItems[indexPath.row]

        let vc = NGODonationDetailsViewController()
        vc.donationId = donation.id
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension NGOAcceptsDonationViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        applyFilters()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

final class NGODonationRequestCell: UITableViewCell {

    static let reuseIdentifier = "NGODonationRequestCell"

    private let cardView = UIView()
    private let pickupImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let donorLabel = UILabel()
    private let statusLabel = UILabel()

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
        pickupImageView.image = UIImage(named: "ImagePicker") ?? UIImage(systemName: "photo")

        let status = donation.status.lowercased()
        let statusColor: UIColor
        if status == "accepted" || status == "approved" {
            statusColor = .systemGreen
        } else if status == "rejected" {
            statusColor = .systemRed
        } else if status == "collected" || status == "completed" {
            statusColor = .systemGray
        } else {
            statusColor = .systemOrange
        }

        statusLabel.text = donation.status.capitalized
        statusLabel.textColor = statusColor
        statusLabel.backgroundColor = statusColor.withAlphaComponent(0.12)
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

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 10
        statusLabel.clipsToBounds = true

        contentView.addSubview(cardView)
        cardView.addSubview(pickupImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(donorLabel)
        cardView.addSubview(statusLabel)
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
            pickupImageView.heightAnchor.constraint(equalToConstant: 120),

            statusLabel.topAnchor.constraint(equalTo: pickupImageView.bottomAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.topAnchor.constraint(equalTo: pickupImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -8),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            donorLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 4),
            donorLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            donorLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            donorLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
        ])
    }
}
