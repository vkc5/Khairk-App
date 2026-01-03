//
//  AddGroupStep3ViewController.swift
//  Khairk
//
//  Created by FM on 17/12/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

private var draft: DonationGroupDraft {
    get { DonationGroupDraftStore.shared.draft }
    set { DonationGroupDraftStore.shared.draft = newValue }
}


final class AddGroupStep3ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    // IMPORTANT: do NOT create a new draft here
    private var draft: DonationGroupDraft {
        DonationGroupDraftStore.shared.draft
    }
    
    @IBAction private func onBackTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    
    
    private let db = Firestore.firestore()
    private var allUsers: [AppUser] = []
    private var selectedMembers: [AppUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()


        tableView.dataSource = self
        navigationItem.hidesBackButton = true
        fetchUsers()
    }

    private func fetchUsers(completion: (() -> Void)? = nil) {
        let currentUID = Auth.auth().currentUser?.uid

        db.collection("users").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.showSimpleAlert(title: "Error", message: error.localizedDescription)
                }
                return
            }

            let docs = snapshot?.documents ?? []
            self.allUsers = docs.compactMap { doc in
                let data = doc.data()
                guard let user = AppUser(id: doc.documentID, data: data) else { return nil }
                return (user.id == currentUID) ? nil : user
            }

            DispatchQueue.main.async { completion?() }
        }
    }

    // MARK: - Add Members (+)
    @IBAction func addTapped(_ sender: UIButton) {
        if allUsers.isEmpty {
            fetchUsers { [weak self] in
                self?.presentMembersSheet(from: sender)
            }
        } else {
            presentMembersSheet(from: sender)
        }
    }
    

    private func presentMembersSheet(from sourceButton: UIButton) {
        if allUsers.isEmpty {
            showSimpleAlert(title: "No Users", message: "No users found in Firestore (users collection).")
            return
        }

        let alert = UIAlertController(title: "Add Members",
                                      message: "Select members",
                                      preferredStyle: .actionSheet)

        for user in allUsers {
            let isSelected = selectedMembers.contains(where: { $0.id == user.id })
            let title = isSelected ? "✓ \(user.name)" : user.name

            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self = self else { return }

                let isSelected = self.selectedMembers.contains(where: { $0.id == user.id })

                if isSelected {
                    self.selectedMembers.removeAll { $0.id == user.id }
                } else {
                    self.selectedMembers.append(user)
                }


                self.tableView.reloadData()
                self.presentMembersSheet(from: sourceButton) // optional (shows ✓)
            }

            alert.addAction(action)
        }

        alert.addAction(UIAlertAction(title: "Done", style: .cancel))

        if let popover = alert.popoverPresentationController {
            popover.sourceView = sourceButton
            popover.sourceRect = sourceButton.bounds
        }

        present(alert, animated: true)
    }

    // MARK: - Next (save group)
    @IBAction func nextTapped(_ sender: UIButton) {

        let groupName = draft.groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        if groupName.isEmpty {
            showSimpleAlert(title: "Missing Group Name", message: "Please enter a group name.")
            return
        }

        if draft.frequencySelection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showSimpleAlert(title: "Missing Frequency", message: "Please select a day/date in Step 2.")
            return
        }

        if selectedMembers.count < 2 {
            showSimpleAlert(title: "Add Members", message: "Please select at least 2 members.")
            return
        }

        let ownerId = Auth.auth().currentUser?.uid ?? "demo-user"


        let membersArray: [[String: String]] = selectedMembers.map {
            ["uid": $0.id, "name": $0.name, "email": $0.email]
        }


        let data: [String: Any] = [
            "ownerId": ownerId,
            "name": groupName,
            "description": draft.groupDescription,
            "frequency": draft.frequencyType,
            "frequencySelection": draft.frequencySelection,
            "startDate": Timestamp(date: draft.startDate),
            "endDate": Timestamp(date: draft.endDate),
            "status": "active",
            "members": membersArray,
            "createdAt": FieldValue.serverTimestamp()
        ]

        sender.isEnabled = false

        db.collection("donationGroups").addDocument(data: data) { [weak self] error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                sender.isEnabled = true

                if let error = error {
                    self.showSimpleAlert(title: "Error", message: error.localizedDescription)
                    return
                }

                NotificationCenter.default.post(name: .groupCreated, object: nil)

                let alert = UIAlertController(title: "Success",
                                              message: "Group created successfully!",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    self.navigationController?.popToViewController(ofClass: DonationGroupsViewController.self,
                                                                  animated: true)
                })
                self.present(alert, animated: true)
            }
        }
    }

    private func showSimpleAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

extension AddGroupStep3ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectedMembers.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let user = selectedMembers[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
    }
}



extension UINavigationController {
    func popToViewController<T: UIViewController>(ofClass: T.Type, animated: Bool) {
        if let vc = viewControllers.first(where: { $0 is T }) {
            popToViewController(vc, animated: animated)
        } else {
            popToRootViewController(animated: animated)
        }
    }
}
