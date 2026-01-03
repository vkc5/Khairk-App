import UIKit
import FirebaseFirestore
import FirebaseAuth

final class RatingViewController: UIViewController, UITextViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var starsStack: UIStackView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!

    // MARK: - Flow Data (لازم يجي من الصفحة اللي قبل)
    var ngoId: String!   // ✅ لازم تمريرها قبل العرض

    // MARK: - Firebase
    private let db = Firestore.firestore()

    // MARK: - Properties
    private let atayaYellow = UIColor(
        red: 0xF7/255,
        green: 0xD4/255,
        blue: 0x4C/255,
        alpha: 1
    )

    private let placeholderText = "Enter your feedback..."
    private var starButtons: [UIButton] = []

    private var selectedRating: Int = 0 {
        didSet { updateSubmitState() }
    }
    // MARK: - Optional Context (coming from ConfirmPickup)
    var caseId: String?
    var donationId: String?
    var donorId: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        buildStars(count: 5)
        setupTextView()
        setupSubmitButton()
        applyPlaceholderIfNeeded()
        updateStars()
        updateSubmitState()
    }

    // MARK: - Build Stars
    private func buildStars(count: Int) {
        starsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        starButtons.removeAll()

        for i in 1...count {
            let button = UIButton(type: .system)
            button.tag = i
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.tintColor = .systemGray3

            button.widthAnchor.constraint(equalToConstant: 34).isActive = true
            button.heightAnchor.constraint(equalToConstant: 34).isActive = true

            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)

            starsStack.addArrangedSubview(button)
            starButtons.append(button)
        }
    }

    // MARK: - Star Action
    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStars()
        animateStar(sender)
    }

    private func updateStars() {
        for button in starButtons {
            if button.tag <= selectedRating {
                button.setImage(UIImage(systemName: "star.fill"), for: .normal)
                button.tintColor = atayaYellow
            } else {
                button.setImage(UIImage(systemName: "star"), for: .normal)
                button.tintColor = .systemGray3
            }
        }
    }

    // ✨ Star Animation
    private func animateStar(_ button: UIButton) {
        button.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: [.allowUserInteraction],
            animations: { button.transform = .identity }
        )
    }

    // MARK: - Submit Button
    private func setupSubmitButton() {
        submitButton.layer.cornerRadius = 14
    }

    private func updateSubmitState() {
        let enabled = selectedRating > 0
        submitButton.isEnabled = enabled
        submitButton.alpha = enabled ? 1.0 : 0.5
    }

    // MARK: - TextView + Placeholder
    private func setupTextView() {
        commentTextView.delegate = self
        commentTextView.layer.cornerRadius = 12
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = UIColor.systemGray4.cgColor
        commentTextView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }

    private func applyPlaceholderIfNeeded() {
        if commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            commentTextView.text = placeholderText
            commentTextView.textColor = .systemGray3
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        applyPlaceholderIfNeeded()
    }

    // MARK: - Submit Action
    @IBAction func submitTapped(_ sender: UIButton) {
        guard selectedRating > 0 else { return }
        guard let ngoId = ngoId, !ngoId.isEmpty else {
            showAlert(title: "Error", message: "Missing NGO ID.")
            return
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(title: "Login Required", message: "Please login first.")
            return
        }

        // ✅ نظّف التعليق
        let raw = commentTextView.text ?? ""
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let comment = (trimmed == placeholderText) ? "" : trimmed

        submitButton.isEnabled = false
        submitButton.alpha = 0.5

        saveRatingAndUpdateAvg(ngoId: ngoId, userId: userId, rating: selectedRating, comment: comment)
        self.navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - Firebase Save + Update Average (Transaction)
    private func saveRatingAndUpdateAvg(ngoId: String, userId: String, rating: Int, comment: String) {

        // collections
        let ratingsRef = db.collection("ngo_ratings").document()     // autoId rating doc
        let statsRef   = db.collection("ngo_stats").document(ngoId) // one doc per NGO

        db.runTransaction({ transaction, errorPointer -> Any? in

            // 1) read stats
            let statsSnap: DocumentSnapshot
            do {
                statsSnap = try transaction.getDocument(statsRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }

            let currentCount = statsSnap.data()?["ratingCount"] as? Int ?? 0
            let currentSum   = statsSnap.data()?["ratingSum"] as? Int ?? 0

            let newCount = currentCount + 1
            let newSum   = currentSum + rating
            let newAvg   = Double(newSum) / Double(newCount)

            // 2) write rating document
            transaction.setData([
                "ngoId": ngoId,
                "userId": userId,
                "rating": rating,
                "comment": comment,
                "createdAt": FieldValue.serverTimestamp()
            ], forDocument: ratingsRef)

            // 3) update stats document
            transaction.setData([
                "ratingCount": newCount,
                "ratingSum": newSum,
                "ratingAvg": newAvg,
                "updatedAt": FieldValue.serverTimestamp()
            ], forDocument: statsRef, merge: true)

            return nil

        }, completion: { [weak self] _, error in
            guard let self = self else { return }

            self.submitButton.isEnabled = true
            self.submitButton.alpha = 1.0

            if let error = error {
                self.showAlert(title: "Failed", message: "Could not submit rating.\n\(error.localizedDescription)")
                return
            }

            let message = """
            Thank you for your feedback!
            Rating: \(self.selectedRating)/5

            Your review matters 💛
            """
            self.showAlert(title: "Thank You", message: message)
        })
    }

    // MARK: - Alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
