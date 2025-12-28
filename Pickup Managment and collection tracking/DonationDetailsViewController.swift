import UIKit
import FirebaseFirestore

final class DonationDetailsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!

    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!

    var donationId: String = ""

    private let service = DonationService()
    private var listener: ListenerRegistration?
    private var currentDonation: Donation?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Donation Details"

        approveButton.layer.cornerRadius = 12
        rejectButton.layer.cornerRadius = 12

        listen()
    }

    deinit { listener?.remove() }

    private func listen() {
        guard !donationId.isEmpty else { return }

        listener = service.listenDonation(donationId: donationId) { [weak self] res in
            guard let self = self else { return }
            switch res {
            case .failure(let err):
                self.showAlert("Error", err.localizedDescription)
            case .success(let d):
                self.currentDonation = d
                self.render(d)
            }
        }
    }

    private func render(_ d: Donation) {
        titleLabel.text = d.foodType
        statusLabel.text = "Status: \(d.status) • Pickup: \(d.pickupStatus)"
        detailsLabel.text =
        """
        Donor: \(d.donorName)
        Quantity: \(d.quantity)
        Case ID: \(d.caseId)
        """

        let decided = (d.status != "pending")
        approveButton.isHidden = decided
        rejectButton.isHidden = decided
    }

    @IBAction func approveTapped(_ sender: Any) {
        guard let d = currentDonation else { return }

        confirm(title: "Approve Donation", message: "Approve this donation?") { [weak self] in
            guard let self = self else { return }

            NGOContext.shared.getNgoId { res in
                switch res {
                case .failure(let err):
                    self.showAlert("Error", err.localizedDescription)
                case .success(let ngoId):
                    self.service.approveDonation(
                        ngoId: ngoId,
                        donationId: d.id,
                        caseId: d.caseId,
                        quantity: d.quantity
                    ) { result in
                        DispatchQueue.main.async {
                            if case .failure(let err) = result {
                                self.showAlert("Approve Failed", err.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
    }

    @IBAction func rejectTapped(_ sender: Any) {
        confirm(title: "Reject Donation", message: "Reject this donation?") { [weak self] in
            guard let self = self else { return }
            self.service.rejectDonation(donationId: self.donationId) { result in
                DispatchQueue.main.async {
                    if case .failure(let err) = result {
                        self.showAlert("Reject Failed", err.localizedDescription)
                    }
                }
            }
        }
    }

    private func confirm(title: String, message: String, yes: @escaping () -> Void) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        a.addAction(UIAlertAction(title: "Yes", style: .default) { _ in yes() })
        present(a, animated: true)
    }

    private func showAlert(_ t: String, _ m: String) {
        let a = UIAlertController(title: t, message: m, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
