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

        contentView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        contentView.layer.cornerRadius = 14
        contentView.clipsToBounds = true

        avatarImageView.layer.cornerRadius = 6
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

    // ✅ UPDATED: now accepts isMe
    func configure(rank: Int, user: LeaderboardUser, isMe: Bool) {
        rankLabel.text = "\(rank)"
        nameLabel.text = user.name
        pointsLabel.text = String(format: "%.1f pts", user.points)

        if isMe {
            contentView.backgroundColor = UIColor(white: 0.90, alpha: 1)
            nameLabel.textColor = .systemBlue
            pointsLabel.textColor = .systemBlue
        }
    }
}
