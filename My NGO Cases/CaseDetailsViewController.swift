import UIKit
import FirebaseAuth
import FirebaseFirestore

final class CaseDetailsViewController: UIViewController {

    // MARK: - Outlets (connect later in storyboard)
    @IBOutlet weak var caseImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!

    @IBOutlet weak var deleteButton: UIButton!

    // MARK: - Inputs (set from MyCasesViewController before segue)
    var caseId: String = ""

    private let db = Firestore.firestore()
    private let service = CaseService()
    private var listener: ListenerRegistration?

    private var ngoId: String {
        Auth.auth().currentUser?.uid ?? "MISSING_NGO_ID"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Case Details"

        deleteButton.layer.cornerRadius = 14
        progressView.layer.cornerRadius = 6
        progressView.clipsToBounds = true

        // Optional placeholder styling
        caseImageView.layer.cornerRadius = 14
        caseImageView.clipsToBounds = true

        startListening()
    }

    deinit {
        listener?.remove()
    }

    private func startListening() {
        guard ngoId != "MISSING_NGO_ID", !caseId.isEmpty else {
            showAlert(title: "Missing Data", message: "Cannot load case details.")
            return
        }

        listener = db.collection("ngos")
            .document(ngoId)
            .collection("cases")
            .document(caseId)
            .addSnapshotListener { [weak self] doc, err in
                guard let self = self else { return }

                if let err = err {
                    self.showAlert(title: "Error", message: err.localizedDescription)
                    return
                }
                guard let doc = doc, let item = NgoCase(doc: doc) else { return }
                self.render(item)
            }
    }

    private func render(_ item: NgoCase) {
        titleLabel.text = item.title
        descriptionLabel.text = item.details

        let fmt = DateFormatter()
        fmt.dateStyle = .medium

        detailsLabel.text =
        """
        Food Type: \(item.foodType)
        Goal: \(item.goal)
        Start Date: \(fmt.string(from: item.startDate))
        End Date: \(fmt.string(from: item.endDate))
        Status: \(item.status)
        """

        let goalSafe = max(item.goal, 1)
        let progress = min(Float(item.collected) / Float(goalSafe), 1.0)
        progressView.setProgress(progress, animated: true)
        progressLabel.text = "\(item.collected) / \(item.goal)"

        // Image loading (optional):
        // If you later store imageURL in Firebase Storage, we can load it here.
        // For now, keep a placeholder image set in storyboard or leave it empty.
    }

    @IBAction func deleteTapped(_ sender: Any) {
        guard ngoId != "MISSING_NGO_ID", !caseId.isEmpty else { return }

        let confirm = UIAlertController(
            title: "Delete Case",
            message: "Are you sure you want to delete this case?",
            preferredStyle: .alert
        )
        confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        confirm.addAction(UIAlertAction(title: "Yes, Delete Case", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.service.deleteCase(ngoId: self.ngoId, caseId: self.caseId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let err):
                        self.showAlert(title: "Delete Failed", message: err.localizedDescription)
                    }
                }
            }
        })
        present(confirm, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
