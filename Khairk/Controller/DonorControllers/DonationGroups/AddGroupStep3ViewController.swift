//
//  AddGroupStep3ViewController 2.swift
//  Khairk
//
//  Created by FM on 17/12/2025.
//


import UIKit

final class AddGroupStep3ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var selectedMembers: [AppUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self

        // إذا تبين تخفين Back اللي فوق (Navigation)
        navigationItem.hidesBackButton = true
    }

    @IBAction func addTapped(_ sender: UIButton) {

        let vc = storyboard?.instantiateViewController(
            withIdentifier: "MembersPickerViewController"
        ) as! MembersPickerViewController

        vc.onDone = { [weak self] picked in
            guard let self = self else { return }

            // Merge بدون تكرار
            let merged = Set(self.selectedMembers).union(picked)
            self.selectedMembers = Array(merged).sorted { $0.name.lowercased() < $1.name.lowercased() }

            self.tableView.reloadData()
        }

        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
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
