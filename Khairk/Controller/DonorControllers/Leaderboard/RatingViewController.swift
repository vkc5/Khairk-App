import UIKit

final class RatingViewController: UIViewController, UITextViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var starsStack: UIStackView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var submitButton: UIButton!
    
    var ngoId: String?
    var caseId: String?
    var donorId: String?
    var donationId: String?

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
        didSet {
            updateSubmitState()
        }
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Rate Your Experience"
        print("Rating got ngoId=\(ngoId ?? "nil"), caseId=\(caseId ?? "nil"), donationId=\(donationId ?? "nil")")
        buildStars(count: 5)
        setupTextView()
        setupSubmitButton()
        applyPlaceholderIfNeeded()
        updateStars()
        updateSubmitState() // submit disabled at start
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
            animations: {
                button.transform = .identity
            }
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
        commentTextView.textContainerInset = UIEdgeInsets(
            top: 12,
            left: 12,
            bottom: 12,
            right: 12
        )
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

        let comment =
        (commentTextView.text == placeholderText) ? "" : commentTextView.text

        let message = """
        Thank you for your feedback!
        Rating: \(selectedRating)/5

        Your review matters 💛
        """

        showAlert(title: "Thank You", message: message)

        // 🔜 لاحقاً:
        // Save rating + comment to Firebase
        // Navigate to another page
    }

    // MARK: - Alert
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
