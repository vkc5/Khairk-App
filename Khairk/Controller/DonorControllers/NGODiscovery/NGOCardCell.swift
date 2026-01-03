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

        // CARD STYLE
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(
            red: 0xE0/255,
            green: 0xE0/255,
            blue: 0xE0/255,
            alpha: 1
        ).cgColor
        contentView.clipsToBounds = true

        // IMAGE STYLE
        ngoImageView.layer.cornerRadius = 12
        ngoImageView.clipsToBounds = true
        ngoImageView.contentMode = .scaleToFill
    }
    func configure(with ngo: CollectorNGO) {

        // 🔴 مهم جدًا: تصفير الحالة (عشان reuse)
        verifiedIcon.isHidden = true
        trustedLabel.isHidden = true

        nameLabel.text = ngo.name

        let status = ngo.applicationStatus
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        // ✅ verified + trusted فقط للـ approved
        if status == "approved" {
            verifiedIcon.isHidden = false
            trustedLabel.isHidden = false
            trustedLabel.text = "Trusted Partner"
        }

        // ✅ ratingLabel حسب الحالة
        switch status {
        case "approved":
            if ngo.ratingCount > 0 {
                ratingLabel.text = String(format: "⭐ %.1f (%d)", ngo.ratingAvg, ngo.ratingCount)
                ratingLabel.textColor = .label
            } else {
                ratingLabel.text = "No ratings yet"
                ratingLabel.textColor = .secondaryLabel
            }

        case "pending":
            ratingLabel.text = "Pending"
            ratingLabel.textColor = .systemOrange

        case "rejected":
            ratingLabel.text = "Rejected"
            ratingLabel.textColor = .systemRed

        default:
            ratingLabel.text = "—"
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
