import UIKit
import FirebaseAuth

final class CreateCaseViewController: UIViewController {

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var foodTypeField: UITextField!
    @IBOutlet weak var goalField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextView: UITextView!

    private let service = CaseService()

    private var ngoId: String {
        Auth.auth().currentUser?.uid ?? "MISSING_NGO_ID"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Case"

        goalField.keyboardType = .numberPad

        // Optional: basic styling for UITextView
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
    }

    @IBAction func saveTapped(_ sender: Any) {
        guard ngoId != "MISSING_NGO_ID" else {
            showAlert(title: "Not Logged In", message: "Please log in as an NGO first.")
            return
        }

        let title = (titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let foodType = (foodTypeField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let goal = Int(goalField.text ?? "") ?? 0
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        let details = (descriptionTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title.isEmpty, !foodType.isEmpty, goal > 0 else {
            showAlert(title: "Missing Info", message: "Enter Title, Food Type, and a valid Goal.")
            return
        }

        if endDate < startDate {
            showAlert(title: "Invalid Dates", message: "End date must be after start date.")
            return
        }

        let newCase = NgoCase(
            id: "temp",
            title: title,
            foodType: foodType,
            goal: goal,
            collected: 0,
            startDate: startDate,
            endDate: endDate,
            details: details,
            imageURL: nil,
            status: "active"
        )

        service.createCase(ngoId: ngoId, newCase: newCase) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self.showAlert(title: "Save Failed", message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
