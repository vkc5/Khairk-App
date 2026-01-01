import UIKit

final class NGOCardCell: UICollectionViewCell {

    @IBOutlet weak var ngoImageView: UIImageView!
    @IBOutlet weak var trustedLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    // ✅ الأيقونة الزرقا (لازم تربطينها)
    @IBOutlet weak var verifiedIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        ngoImageView.layer.cornerRadius = 12
        ngoImageView.clipsToBounds = true

        // ✅ Stretch (تملي المكان)
        ngoImageView.contentMode = .scaleToFill
    }


    func configure(with ngo: CollectorNGO) {
        nameLabel.text = ngo.name

        let status = ngo.applicationStatus.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // ✅ verified icon يطلع بس للـ approved
        verifiedIcon.isHidden = (status != "approved")

        // ✅ trusted label
        trustedLabel.text = "Trusted Partner"
        trustedLabel.isHidden = (status != "approved")

        // ✅ status label + لون حسب الحالة
        switch status {
        case "approved":
            ratingLabel.text = "Approved"
            ratingLabel.textColor = .systemGreen
        case "pending":
            ratingLabel.text = "Pending"
            ratingLabel.textColor = .systemOrange
        case "rejected":
            ratingLabel.text = "Rejected"
            ratingLabel.textColor = .systemRed
        default:
            ratingLabel.text = ngo.applicationStatus.isEmpty ? "—" : ngo.applicationStatus
            ratingLabel.textColor = .secondaryLabel
        }

        distanceLabel.text = ngo.serviceArea.isEmpty ? "" : "Area: \(ngo.serviceArea)"

        let urlString = !ngo.profileImageUrl.isEmpty ? ngo.profileImageUrl : ngo.logoUrl
        loadImage(from: urlString)
    }

    private func loadImage(from urlString: String) {
        ngoImageView.image = UIImage(named: "placeholder")

        guard let url = URL(string: urlString), !urlString.isEmpty else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.ngoImageView.image = img
            }
        }.resume()
    }
}
