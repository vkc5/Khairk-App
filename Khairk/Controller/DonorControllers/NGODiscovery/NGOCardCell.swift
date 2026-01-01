import UIKit

final class NGOCardCell: UICollectionViewCell {

    @IBOutlet weak var ngoImageView: UIImageView!
    @IBOutlet weak var trustedLabel: UILabel!   // you can use it as "Trusted Partner" OR status
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!    // we will show status here for now
    @IBOutlet weak var distanceLabel: UILabel!  // we will show serviceArea here

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        ngoImageView.layer.cornerRadius = 12
        ngoImageView.clipsToBounds = true
    }

    func configure(with ngo: CollectorNGO) {
        nameLabel.text = ngo.name

        // You don't have rating/reviews yet in Firestore users,
        // so we show applicationStatus + serviceArea (you can change later)
        ratingLabel.text = "Status: \(ngo.applicationStatus)"
        distanceLabel.text = ngo.serviceArea.isEmpty ? "" : "Area: \(ngo.serviceArea)"

        // If you want "Trusted Partner" always:
        // trustedLabel.text = "Trusted Partner"
        // trustedLabel.isHidden = false

        // Or show the status label:
        trustedLabel.text = "Trusted Partner"
        trustedLabel.isHidden = ngo.applicationStatus != "approved"


        // Load image (prefer profileImageUrl, fallback to logoUrl)
        let urlString = !ngo.profileImageUrl.isEmpty ? ngo.profileImageUrl : ngo.logoUrl
        loadImage(from: urlString)
    }

    private func loadImage(from urlString: String) {
        ngoImageView.image = UIImage(named: "placeholder") // add placeholder asset if you have

        guard let url = URL(string: urlString), !urlString.isEmpty else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.ngoImageView.image = img
            }
        }.resume()
    }
}
