
import UIKit

final class CollectorDetailsViewController: UIViewController {

    // MARK: - Outlets (MATCH STORYBOARD EXACTLY)
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var donateButton: UIButton!

    // MARK: - Data
    var ngo: CollectorNGO!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        styleUI()
        fillData()

        view.backgroundColor = .systemGroupedBackground
        title = "Details"
    }


    // MARK: - UI Styling
    private func styleUI() {
        // Hero image
        heroImageView.layer.cornerRadius = 20
        heroImageView.clipsToBounds = true
        heroImageView.contentMode = .scaleAspectFill

        // Donate button
        donateButton.layer.cornerRadius = 24
        donateButton.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 70/255, alpha: 1)
        donateButton.setTitleColor(.white, for: .normal)

        // TextView (acts like label)
        descriptionTextView.isEditable = false
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.textContainerInset = .zero
        descriptionTextView.textContainer.lineFragmentPadding = 0
    }


    // MARK: - Fill Data
    private func fillData() {
        nameLabel.text = ngo.name

        // You don't have distance/rating in Firestore, so show placeholders
        distanceLabel.text = ngo.serviceArea.isEmpty ? "—" : ngo.serviceArea
        ratingLabel.text = "Approved NGO ⭐"

        emailLabel.text = ngo.email.isEmpty ? "—" : ngo.email
        phoneLabel.text = ngo.phone.isEmpty ? "—" : ngo.phone

        descriptionTextView.text = "This NGO supports the community by collecting and distributing food donations."

        let urlString = !ngo.profileImageUrl.isEmpty ? ngo.profileImageUrl : ngo.logoUrl
        loadImage(from: urlString)
        print("IMAGE URL:",urlString)
        nameLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = .label

        ratingLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        ratingLabel.textColor = UIColor.systemGreen

        distanceLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        distanceLabel.textColor = .secondaryLabel
        emailLabel.font = UIFont.systemFont(ofSize: 14)
        emailLabel.textColor = .secondaryLabel

        phoneLabel.font = UIFont.systemFont(ofSize: 14)
        phoneLabel.textColor = .secondaryLabel
    }

    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString), !urlString.isEmpty else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.heroImageView.image = image
            }
        }.resume()
    }

    // MARK: - Action
    @IBAction func donateNowTapped(_ sender: UIButton) {
        print("Donate Now tapped for:", ngo.name)
    }
    
}
