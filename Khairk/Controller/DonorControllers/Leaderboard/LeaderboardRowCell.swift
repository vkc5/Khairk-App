import UIKit

final class LeaderboardRowCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        backgroundColor = .clear

        // row "pill" look
        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        contentView.layer.cornerRadius = 14
        contentView.clipsToBounds = true

        // ✅ square avatar (not circle)
        avatarImageView.layer.cornerRadius = 6   // set 0 if you want sharp corners
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.image = UIImage(systemName: "person.crop.square.fill")

        rankLabel.textColor = .darkGray
        pointsLabel.textColor = .darkGray
        nameLabel.textColor = .black
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = UIImage(systemName: "person.crop.square.fill")
        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        nameLabel.textColor = .black
        pointsLabel.textColor = .darkGray
    }

    func configure(rank: Int, user: LeaderboardUser) {
        rankLabel.text = "\(rank)"
        nameLabel.text = user.name
        pointsLabel.text = String(format: "%.1f pts", user.points)

        // If you later want to load image from URL, tell me and I’ll add it.
    }
}
