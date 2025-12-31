import UIKit
import FirebaseAuth
import FirebaseFirestore

final class MyCasesViewController: UIViewController {

    private enum Filter: CaseIterable {
        case all
        case seventyFive
        case fifty
        case twentyFive

        var title: String {
            switch self {
            case .all:
                return "All"
            case .seventyFive:
                return "75%+"
            case .fifty:
                return "50%+"
            case .twentyFive:
                return "25%+"
            }
        }

        func matches(progress: Float) -> Bool {
            switch self {
            case .all:
                return true
            case .seventyFive:
                return progress >= 0.75
            case .fifty:
                return progress >= 0.5
            case .twentyFive:
                return progress >= 0.25
            }
        }
    }

    private let service = CaseService()
    private var listener: ListenerRegistration?
    private var cases: [NgoCase] = []
    private var filteredCases: [NgoCase] = []
    private var selectedFilter: Filter = .all
    private var searchText: String = ""

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let headerView = UIView()
    private let searchBar = UISearchBar()
    private let chipsStack = UIStackView()
    private let emptyLabel = UILabel()

    private var chipButtons: [UIButton] = []

    private var ngoId: String {
        Auth.auth().currentUser?.uid ?? "MISSING_NGO_ID"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My NGO Cases"
        view.backgroundColor = .systemBackground

        setupNavigationBar()
        setupTableView()
        setupHeader()
        setupEmptyState()

        startListening()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderLayout()
    }

    deinit {
        listener?.remove()
    }

    @objc private func addTapped() {
        let createVC = CreateCaseViewController()
        navigationController?.pushViewController(createVC, animated: true)
    }

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "MainBrand-500") ?? UIColor.systemGreen
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationItem.largeTitleDisplayMode = .never

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )
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
        tableView.register(NgoCaseCardCell.self, forCellReuseIdentifier: NgoCaseCardCell.reuseIdentifier)

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

        chipsStack.axis = .horizontal
        chipsStack.spacing = 8
        chipsStack.distribution = .fillProportionally
        chipsStack.translatesAutoresizingMaskIntoConstraints = false

        chipButtons = Filter.allCases.enumerated().map { index, filter in
            let button = UIButton(type: .system)
            button.setTitle(filter.title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            button.layer.cornerRadius = 14
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemGray4.cgColor
            button.backgroundColor = UIColor.systemGray6
            button.setTitleColor(.label, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
            return button
        }

        chipButtons.forEach { chipsStack.addArrangedSubview($0) }
        updateChipSelection()

        headerStack.addArrangedSubview(searchBar)
        headerStack.addArrangedSubview(chipsStack)
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
        emptyLabel.text = "No cases yet"
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

    private func startListening() {
        guard ngoId != "MISSING_NGO_ID" else {
            showAlert(title: "Not Logged In", message: "Please log in as an NGO first.")
            return
        }

        listener = service.listenCases(ngoId: ngoId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let items):
                self.cases = items
                self.applyFilters()
            case .failure(let error):
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }

    private func applyFilters() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        filteredCases = cases.filter { item in
            let progress = item.goal > 0 ? Float(item.collected) / Float(item.goal) : 0
            let matchesFilter = selectedFilter.matches(progress: progress)
            let matchesQuery = query.isEmpty
                || item.title.lowercased().contains(query)
                || item.foodType.lowercased().contains(query)
            return matchesFilter && matchesQuery
        }

        emptyLabel.isHidden = !filteredCases.isEmpty
        tableView.reloadData()
    }

    @objc private func filterTapped(_ sender: UIButton) {
        let index = sender.tag
        guard index >= 0, index < Filter.allCases.count else { return }
        selectedFilter = Filter.allCases[index]
        updateChipSelection()
        applyFilters()
    }

    private func updateChipSelection() {
        for (index, button) in chipButtons.enumerated() {
            let isSelected = Filter.allCases[index] == selectedFilter
            button.backgroundColor = isSelected
                ? (UIColor(named: "MainBrand-500") ?? UIColor.systemGreen)
                : UIColor.systemGray6
            button.setTitleColor(isSelected ? .white : .label, for: .normal)
            button.layer.borderColor = isSelected ? UIColor.clear.cgColor : UIColor.systemGray4.cgColor
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension MyCasesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: NgoCaseCardCell.reuseIdentifier,
            for: indexPath
        ) as? NgoCaseCardCell else {
            return UITableViewCell()
        }

        cell.configure(with: filteredCases[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = filteredCases[indexPath.row]

        let detailsVC = CaseDetailsViewController()
        detailsVC.caseId = item.id
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}

extension MyCasesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        applyFilters()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

final class NgoCaseCardCell: UITableViewCell {

    static let reuseIdentifier = "NgoCaseCardCell"

    private let cardView = UIView()
    private let caseImageView = UIImageView()
    private let tagLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let progressLabel = UILabel()
    private let metaLabel = UILabel()

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

    func configure(with item: NgoCase) {
        titleLabel.text = item.title
        descriptionLabel.text = item.details

        let goalSafe = max(item.goal, 1)
        let progress = min(Float(item.collected) / Float(goalSafe), 1)
        progressView.setProgress(progress, animated: false)
        progressLabel.text = "\(Int(progress * 100))%"

        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: item.endDate).day ?? 0
        let status = tagText(status: item.status, daysLeft: daysLeft)
        tagLabel.text = status
        tagLabel.isHidden = status.isEmpty

        metaLabel.text = "Raised \(Int(progress * 100))%  •  Days left \(max(daysLeft, 0))"

        caseImageView.image = UIImage(named: "ImagePicker") ?? UIImage(systemName: "photo")
    }

    private func tagText(status: String, daysLeft: Int) -> String {
        if status.lowercased() == "new" {
            return "New"
        }
        if daysLeft <= 7 {
            return "Expiring Soon"
        }
        return ""
    }

    private func setupCard() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)

        caseImageView.translatesAutoresizingMaskIntoConstraints = false
        caseImageView.contentMode = .scaleAspectFill
        caseImageView.clipsToBounds = true
        caseImageView.layer.cornerRadius = 12

        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        tagLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        tagLabel.textColor = UIColor(named: "MainBrand-500") ?? UIColor.systemGreen
        tagLabel.backgroundColor = UIColor(named: "MainBrand-50") ?? UIColor.systemGreen.withAlphaComponent(0.1)
        tagLabel.textAlignment = .center
        tagLabel.layer.cornerRadius = 10
        tagLabel.clipsToBounds = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.numberOfLines = 2

        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.trackTintColor = UIColor.systemGray5
        progressView.progressTintColor = UIColor(named: "MainBrand-500") ?? UIColor.systemGreen
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true

        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        progressLabel.textColor = .label

        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        metaLabel.font = UIFont.systemFont(ofSize: 11)
        metaLabel.textColor = .secondaryLabel

        contentView.addSubview(cardView)
        cardView.addSubview(caseImageView)
        cardView.addSubview(tagLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(progressView)
        cardView.addSubview(progressLabel)
        cardView.addSubview(metaLabel)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            caseImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            caseImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            caseImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            caseImageView.heightAnchor.constraint(equalToConstant: 140),

            tagLabel.topAnchor.constraint(equalTo: caseImageView.bottomAnchor, constant: 10),
            tagLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            tagLabel.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.topAnchor.constraint(equalTo: caseImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: tagLabel.leadingAnchor, constant: -8),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            progressView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            progressView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            progressView.heightAnchor.constraint(equalToConstant: 6),

            progressLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 6),
            progressLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),

            metaLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 6),
            metaLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            metaLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
        ])
    }
}
