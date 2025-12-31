//
//  MemberPickerViewController.swift
//  Khairk
//
//  Created by FM on 17/12/2025.
//


import UIKit

final class MembersPickerViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let service = UsersService()
    private var users: [AppUser] = []

    // Multi-select storage
    private var selectedSet = Set<AppUser>()

    // Callback يرجّع المختارين للشاشة اللي قبل
    var onDone: (([AppUser]) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true

        loadUsers()
    }

    private func loadUsers() {
        service.fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self?.users = users.sorted { $0.name.lowercased() < $1.name.lowercased() }
                    self?.tableView.reloadData()

                case .failure(let error):
                    self?.showError(error.localizedDescription)
                }
            }
        }
    }

    private func showError(_ msg: String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func doneTapped(_ sender: Any) {
        onDone?(Array(selectedSet))
        dismiss(animated: true)
    }
}

extension MembersPickerViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let user = users[indexPath.row]

        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        cell.selectionStyle = .none
        cell.accessoryType = selectedSet.contains(user) ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        selectedSet.insert(user)
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        selectedSet.remove(user)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
