import UIKit

final class CollectorDetailsViewController: UIViewController {

    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var donateButton: UIButton!

    var ngo: CollectorNGO?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Details"

        styleUI()
        fillData()
    }

    private func styleUI() {
        heroImageView.layer.cornerRadius = 20
        heroImageView.clipsToBounds = true
        heroImageView.contentMode = .scaleToFill
        heroImageView.clipsToBounds = true

        donateButton.layer.cornerRadius = 24
        donateButton.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 70/255, alpha: 1)
        donateButton.setTitleColor(.white, for: .normal)

        descriptionTextView.isEditable = false
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.backgroundColor = .clear
        descriptionTextView.textContainerInset = .zero
        descriptionTextView.textContainer.lineFragmentPadding = 0
    }

    private func fillData() {
        guard let ngo else { return }

        nameLabel.text = ngo.name
        distanceLabel.text = ngo.serviceArea.isEmpty ? "—" : ngo.serviceArea
        emailLabel.text = ngo.email.isEmpty ? "—" : ngo.email
        phoneLabel.text = ngo.phone.isEmpty ? "—" : ngo.phone

        descriptionTextView.text = "This NGO supports the community by collecting and distributing food donations."

        let status = ngo.applicationStatus.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        switch status {
        case "approved":
            ratingLabel.text = "Approved NGO ⭐"
            ratingLabel.textColor = .systemGreen
            donateButton.isHidden = false
            donateButton.isEnabled = true

        case "pending":
            ratingLabel.text = "Pending Review ⏳"
            ratingLabel.textColor = .systemOrange
            donateButton.isHidden = true   // ✅ لا يسمح يتبرع وهو pending
            donateButton.isEnabled = false

        case "rejected":
            ratingLabel.text = "Rejected ✖︎"
            ratingLabel.textColor = .systemRed
            donateButton.isHidden = true
            donateButton.isEnabled = false

        default:
            ratingLabel.text = ngo.applicationStatus.isEmpty ? "Status: —" : "Status: \(ngo.applicationStatus)"
            ratingLabel.textColor = .secondaryLabel
            donateButton.isHidden = true
            donateButton.isEnabled = false
        }

        let urlString = !ngo.profileImageUrl.isEmpty ? ngo.profileImageUrl : ngo.logoUrl
        loadImage(from: urlString)
    }

    private func loadImage(from urlString: String) {
        let clean = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty,
              let url = URL(string: clean),
              let scheme = url.scheme?.lowercased(),
              scheme == "https" else {
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.heroImageView.image = image }
        }.resume()
    }

    @IBAction func donateNowTapped(_ sender: UIButton) {
        guard let ngo else { return }
        let storyboard = UIStoryboard(name: "DonorNGOCases", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "FoodDonationViewController")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

}
