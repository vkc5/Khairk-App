import UIKit
import FirebaseAuth
import FirebaseFirestore

final class MyCasesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let service = CaseService()
    private var listener: ListenerRegistration?
    private var cases: [NgoCase] = []

    // IMPORTANT:
    // Set this to the current NGO id.
    // Best practice: use Auth UID as NGO doc id.
    private var ngoId: String {
        Auth.auth().currentUser?.uid ?? "MISSING_NGO_ID"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My NGO Cases"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        startListening()
    }

    deinit {
        listener?.remove()
    }

    private func startListening() {
        guard ngoId != "MISSING_NGO_ID" else {
            print("No logged-in user. Cannot load NGO cases.")
            return
        }

        listener = service.listenCases(ngoId: ngoId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let items):
                self.cases = items
                self.tableView.reloadData()
            case .failure(let error):
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }

    @IBAction func addTapped(_ sender: Any) {
        performSegue(withIdentifier: "toCreateCase", sender: nil)
    }

    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

extension MyCasesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CaseCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "CaseCell")

        let item = cases[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = "\(item.foodType) • \(item.collected)/\(item.goal) • \(item.status)"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // swipe-to-delete
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {

        guard editingStyle == .delete else { return }
        let item = cases[indexPath.row]

        let confirm = UIAlertController(
            title: "Delete Case?",
            message: "This will permanently delete \"\(item.title)\".",
            preferredStyle: .alert
        )
        confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirm.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.service.deleteCase(ngoId: self.ngoId, caseId: item.id) { result in
                if case .failure(let err) = result {
                    self.showAlert(title: "Delete Failed", message: err.localizedDescription)
                }
            }
        })
        present(confirm, animated: true)
    }
}
