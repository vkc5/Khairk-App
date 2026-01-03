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
        let foodName: String
        let quantity: Int
        let status: DonationStatus
        let imageURL: String?
        let createdAt: Date?

        // Details screen fields
        let note: String?
        let expiryDate: Date?
        let donationType: String? // "pickup" or "delivery"

        // Delivery fields
        let serviceArea: String?
        let street: String?
        let block: String?
        let buildingNumber: String?

        // Pickup field
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

        // Force one-line title
        config.titleLineBreakMode = .byTruncatingTail

        // Padding using configuration insets
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)

        // Default (unselected) style
        config.baseBackgroundColor = unselectedBg
        config.baseForegroundColor = unselectedText

        // Smaller font to prevent wrapping
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
            print("❌ No logged in user")
            return
        }

        listener = db.collection("donations")
            .whereField("donorId", isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Tracking error:", error)
                    return
                }

                let docs = snapshot?.documents ?? []
                print("✅ ALL donations count =", docs.count)

                // Debug: print first doc
                if let first = docs.first {
                    let d = first.data()
                    print("🔎 first doc donorId:", d["donorId"] ?? "nil",
                          "foodName:", d["foodName"] ?? "nil")
                }

                let mapped: [DonationItem] = docs.compactMap { doc in
                    let data = doc.data()

                    // ✅ donorId (required by your struct)
                    let donorId = data["donorId"] as? String ?? ""

                    let foodName = (data["foodName"] as? String) ?? "Unknown"

                    // quantity can be Int or Double
                    let quantity: Int = {
                        if let i = data["quantity"] as? Int { return i }
                        if let d = data["quantity"] as? Double { return Int(d) }
                        return 0
                    }()

                    let statusStr = ((data["status"] as? String) ?? "pending").lowercased()
                    let status = DonationStatus(rawValue: statusStr) ?? .pending

                    let imageURL = data["imageURL"] as? String
                    let createdAt = (data["createdAt"] as? Timestamp)?.dateValue()

                    // Details fields
                    let note = data["description"] as? String ?? data["note"] as? String
                    let expiryDate = (data["expiryDate"] as? Timestamp)?.dateValue()
                    let donationType = data["donationType"] as? String

                    // Delivery fields
                    let serviceArea = data["serviceArea"] as? String
                    let street = data["street"] as? String
                    let block = data["block"] as? String
                    let buildingNumber = data["buildingNumber"] as? String

                    // Pickup field
                    let pickupTime = (data["pickupTime"] as? Timestamp)?.dateValue()

                    return DonationItem(
                        donorId: donorId,
                        id: doc.documentID,
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

    // MARK: - Navigation
    private func openDetails(_ item: DonationItem) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "ViewDetailsViewController") as? ViewDetailsViewController else {
            assertionFailure("Missing storyboard ID: ViewDetailsViewController")
            return
        }
        vc.item = item
        navigationController?.pushViewController(vc, animated: true)
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

        // Handle "View Details" tap from the cell
        cell.onViewDetailsTapped = { [weak self] in
            self?.openDetails(item)
        }

        return cell
    }
}
