//
//  DonationTrackingViewController.swift
//  Khairk
//
//  Created by FM on 18/12/2025.
//



import UIKit
import FirebaseFirestore
import FirebaseAuth

final class DonationTrackingViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!

    @IBOutlet private weak var allButton: UIButton!
    @IBOutlet private weak var acceptedButton: UIButton!
    @IBOutlet private weak var collectedButton: UIButton!
    @IBOutlet private weak var deliveredButton: UIButton!

    // MARK: - Firestore
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - Model
    enum DonationStatus: String {
        case pending
        case accepted
        case collected
        case delivered

        var title: String { rawValue.capitalized }

        var progress: Float {
            switch self {
            case .pending:   return 0.10
            case .accepted:  return 0.33
            case .collected: return 0.66
            case .delivered: return 1.00
            }
        }
    }

    struct DonationItem {
        let donorId: String
        let id: String
        let caseId: String

        let foodName: String
        let quantity: Int
        let status: DonationStatus
        let imageURL: String?
        let createdAt: Date?

        let note: String?
        let expiryDate: Date?
        let donationType: String?

        let serviceArea: String?
        let street: String?
        let block: String?
        let buildingNumber: String?

        let pickupTime: Date?
    }

    enum Filter { case all, accepted, collected, delivered }
    private var currentFilter: Filter = .all

    private var allItems: [DonationItem] = []
    private var visibleItems: [DonationItem] = []

    private var tabButtons: [UIButton] { [allButton, acceptedButton, collectedButton, deliveredButton] }

    // MARK: - Tab Colors
    private let selectedBg = UIColor.mainBrand500
    private let unselectedBg = UIColor.systemGray5
    private let selectedText = UIColor.white
    private let unselectedText = UIColor.black

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "My Donation"

        setupTable()
        setupTabsUI()

        applyFilter(.all)
        fetchDonations()
    }

    deinit { listener?.remove() }

    // MARK: - Setup
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 220

        tableView.backgroundColor = .white
        view.backgroundColor = .white
    }

    private func setupTabsUI() {
        allButton.setTitle("All", for: .normal)
        acceptedButton.setTitle("Accepted", for: .normal)
        collectedButton.setTitle("Collected", for: .normal)
        deliveredButton.setTitle("Delivered", for: .normal)

        tabButtons.forEach { btn in
            btn.configuration = makeTabConfig(title: btn.currentTitle ?? "")
        }

        setSelectedTab(allButton)
    }

    private func makeTabConfig(title: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.title = title
        config.titleLineBreakMode = .byTruncatingTail
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        config.baseBackgroundColor = unselectedBg
        config.baseForegroundColor = unselectedText

        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            return outgoing
        }

        return config
    }

    private func setSelectedTab(_ selected: UIButton) {
        tabButtons.forEach { btn in
            guard var cfg = btn.configuration else { return }
            cfg.baseBackgroundColor = unselectedBg
            cfg.baseForegroundColor = unselectedText
            cfg.title = btn.currentTitle
            btn.configuration = cfg
        }

        if var cfg = selected.configuration {
            cfg.baseBackgroundColor = selectedBg
            cfg.baseForegroundColor = selectedText
            cfg.title = selected.currentTitle
            selected.configuration = cfg
        }
    }

    private func applyFilter(_ filter: Filter) {
        currentFilter = filter

        switch filter {
        case .all:
            visibleItems = allItems
            setSelectedTab(allButton)

        case .accepted:
            visibleItems = allItems.filter { $0.status == .accepted }
            setSelectedTab(acceptedButton)

        case .collected:
            visibleItems = allItems.filter { $0.status == .collected }
            setSelectedTab(collectedButton)

        case .delivered:
            visibleItems = allItems.filter { $0.status == .delivered }
            setSelectedTab(deliveredButton)
        }

        tableView.reloadData()
    }

    // MARK: - Firestore
    private func fetchDonations() {
        listener?.remove()

        guard let uid = Auth.auth().currentUser?.uid else {
            print("No logged in user")
            return
        }

        listener = db.collection("donations")
            .whereField("donorId", isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Tracking error:", error)
                    return
                }

                let docs = snapshot?.documents ?? []
                print("ALL donations count =", docs.count)

                let mapped: [DonationItem] = docs.compactMap { doc in
                    let data = doc.data()

                    let donorId = data["donorId"] as? String ?? ""
                    let caseId = (data["caseId"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    let foodName = (data["foodName"] as? String) ?? "Unknown"

                    let quantity: Int = {
                        if let i = data["quantity"] as? Int { return i }
                        if let d = data["quantity"] as? Double { return Int(d) }
                        return 0
                    }()

                    let statusStr = ((data["status"] as? String) ?? "pending").lowercased()
                    let status = DonationStatus(rawValue: statusStr) ?? .pending

                    let imageURL = data["imageURL"] as? String
                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()

                    let note = data["description"] as? String ?? data["note"] as? String
                    let expiryDate = (data["expiryDate"] as? Timestamp)?.dateValue()
                    let donationType = data["donationType"] as? String

                    let serviceArea = data["serviceArea"] as? String
                    let street = data["street"] as? String
                    let block = data["block"] as? String
                    let buildingNumber = data["buildingNumber"] as? String

                    let pickupTime = (data["pickupTime"] as? Timestamp)?.dateValue()

                    return DonationItem(
                        donorId: donorId,
                        id: doc.documentID,
                        caseId: caseId,
                        foodName: foodName,
                        quantity: quantity,
                        status: status,
                        imageURL: imageURL,
                        createdAt: createdAt,
                        note: note,
                        expiryDate: expiryDate,
                        donationType: donationType,
                        serviceArea: serviceArea,
                        street: street,
                        block: block,
                        buildingNumber: buildingNumber,
                        pickupTime: pickupTime
                    )
                }

                DispatchQueue.main.async {
                    self.allItems = mapped
                    self.applyFilter(.all)
                }
            }
    }

    // MARK: - Actions
    @IBAction private func allTapped(_ sender: UIButton) { applyFilter(.all) }
    @IBAction private func acceptedTapped(_ sender: UIButton) { applyFilter(.accepted) }
    @IBAction private func collectedTapped(_ sender: UIButton) { applyFilter(.collected) }
    @IBAction private func deliveredTapped(_ sender: UIButton) { applyFilter(.delivered) }

    // MARK: - Segue Passing (FIXED)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "ShowContactNGO" else { return }

        // Destination VC (handles if embedded in nav controller)
        let destinationVC: ContactNGOViewController? = {
            if let nav = segue.destination as? UINavigationController {
                return nav.topViewController as? ContactNGOViewController
            } else {
                return segue.destination as? ContactNGOViewController
            }
        }()

        guard let vc = destinationVC else {
            print("❌ Destination is not ContactNGOViewController")
            return
        }

        //Find which row triggered the segue (works for button or row)
        var indexPath: IndexPath?

        // 1) sender is a cell
        if let cell = sender as? UITableViewCell {
            indexPath = tableView.indexPath(for: cell)
        }

        // 2) sender is a view inside a cell (button)
        if indexPath == nil, let view = sender as? UIView {
            let point = view.convert(CGPoint.zero, to: tableView)
            indexPath = tableView.indexPathForRow(at: point)
        }

        // 3) fallback
        if indexPath == nil {
            indexPath = tableView.indexPathForSelectedRow
        }

        guard let finalIndexPath = indexPath else {
            print("Could not find indexPath for sender:", String(describing: sender))
            return
        }

        let item = visibleItems[finalIndexPath.row]
        let trimmedCaseId = item.caseId.trimmingCharacters(in: .whitespacesAndNewlines)

        print("Passing caseId to ContactNGO =", "[\(trimmedCaseId)]", "row:", finalIndexPath.row)

        vc.caseId = trimmedCaseId
    }
}

// MARK: - Table
extension DonationTrackingViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visibleItems.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DonationCardCell",
                                                       for: indexPath) as? DonationCardCell else {
            return UITableViewCell()
        }

        let item = visibleItems[indexPath.row]
        cell.configure(
            foodName: item.foodName,
            quantity: item.quantity,
            statusText: item.status.title,
            progress: item.status.progress,
            imageURL: item.imageURL
        )

        // View details button stays same
        cell.onViewDetailsTapped = { [weak self] in
            guard let self = self else { return }
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewDetailsViewController") as? ViewDetailsViewController else {
                assertionFailure("Missing storyboard ID: ViewDetailsViewController")
                return
            }
            vc.item = item
            self.navigationController?.pushViewController(vc, animated: true)
        }

        return cell
    }

    //  If you tap the row, open the same segue correctly (sender = cell)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowContactNGO", sender: tableView.cellForRow(at: indexPath))
    }
}
