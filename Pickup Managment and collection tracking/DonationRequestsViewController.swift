import UIKit
import FirebaseFirestore

final class DonationRequestsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let service = DonationService()
    private var listener: ListenerRegistration?
    private var items: [Donation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accepts donation"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        load()
    }

    deinit { listener?.remove() }

    private func load() {
        NGOContext.shared.getNgoId { [weak self] res in
            guard let self = self else { return }
            switch res {
            case .failure(let err):
                self.showAlert("Error", err.localizedDescription)
            case .success(let ngoId):
                self.listener = self.service.listenPendingDonations(ngoId: ngoId) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let list):
                        self.items = list
                        self.tableView.reloadData()
                    case .failure(let err):
                        self.showAlert("Error", err.localizedDescription)
                    }
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDonationDetails",
           let vc = segue.destination as? DonationDetailsViewController,
           let donation = sender as? Donation {
            vc.donationId = donation.id
        }
    }

    private func showAlert(_ t: String, _ m: String) {
        let a = UIAlertController(title: t, message: m, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}

extension DonationRequestsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DonationCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "DonationCell")

        let d = items[indexPath.row]
        cell.textLabel?.text = d.foodType
        cell.detailTextLabel?.text = "\(d.donorName) • qty \(d.quantity) • \(d.status)"
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "toDonationDetails", sender: items[indexPath.row])
    }
}
