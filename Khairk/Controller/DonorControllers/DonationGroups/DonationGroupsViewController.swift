//
//  DonationGroupsViewController.swift
//  Khairk
//
//  Created by FM on 15/12/2025.
//

import UIKit
import FirebaseFirestore

final class DonationGroupsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addGroupButton: UIButton!

    private let db = Firestore.firestore()

    private var allGroups: [DonationGroupItem] = []
    private var filteredGroups: [DonationGroupItem] = []

    private var groupsListener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupSearchBar()
        setupAddButton()

        // ✅ Listen for "group created" and refresh
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadGroups),
            name: .groupCreated,
            object: nil
        )

        // ✅ First load (real-time)
        startListeningForGroups()
    }

    deinit {
        groupsListener?.remove()
        NotificationCenter.default.removeObserver(self)
    }

    // ✅ Called when Step3 posts .groupCreated
    @objc private func reloadGroups() {
        print("🔄 Reloading groups after creation")
        startListeningForGroups()
    }

    // ✅ Real-time listener (NO ownerId filter)
    private func startListeningForGroups() {
        groupsListener?.remove()

        groupsListener = db.collection("donationGroups")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ listener error:", error.localizedDescription)
                    return
                }

                let items: [DonationGroupItem] = snap?.documents.compactMap { doc in
                    DonationGroupItem(doc: doc)
                } ?? []

                DispatchQueue.main.async {
                    self.allGroups = items
                    self.applySearchFilter()
                }
            }
    }

    private func applySearchFilter() {
        let query = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if query.isEmpty {
            filteredGroups = allGroups
        } else {
            filteredGroups = allGroups.filter {
                $0.name.lowercased().contains(query.lowercased())
            }
        }

        tableView.reloadData()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search groups"
    }

    private func setupAddButton() {
        
        addGroupButton.clipsToBounds = true
    }

    @IBAction func addGroupTapped(_ sender: UIButton) {
        print("Add Group tapped")
        // push Step1
    }
}

// MARK: - UITableViewDataSource
extension DonationGroupsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredGroups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath) as! GroupCell
        cell.configure(with: filteredGroups[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DonationGroupsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension DonationGroupsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearchFilter()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
