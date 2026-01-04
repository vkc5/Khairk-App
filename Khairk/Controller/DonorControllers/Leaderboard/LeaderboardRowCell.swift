import UIKit

final class LeaderboardRowCell: UITableViewCell {

    // MARK: - Outlets (من الستوري بورد)
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!

    // MARK: - Card Wrapper (يسوي مسافات + بوردر)
    private let cardView = UIView()
    private static let imageCache = NSCache<NSString, UIImage>()

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // 1) جهزي CardView
        setupCardView()

        // 2) انقلي العناصر داخل CardView (بدون ما تحتاجين تعدلين ستوري بورد)
        moveSubviewsIntoCard()

        // 3) ستايل العناصر
        styleLabels()
        styleAvatar()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = defaultAvatar()
        avatarImageView.tintColor = .systemGray3
        avatarImageView.backgroundColor = UIColor.systemGray6

        nameLabel.textColor = .black
        pointsLabel.textColor = .darkGray
        cardView.backgroundColor = .white
        cardView.layer.borderColor = UIColor.systemGray3.cgColor
    }

    // MARK: - Public
    func configure(rank: Int, user: LBUser, isMe: Bool) {
        rankLabel.text = "\(rank)"
        nameLabel.text = user.name
        pointsLabel.text = String(format: "%.1f pts", user.points)

        // default
        avatarImageView.image = defaultAvatar()
        avatarImageView.tintColor = .systemGray3
        avatarImageView.backgroundColor = UIColor.systemGray6

        // load if url exists
        if let urlStr = user.profileImageUrl,
           !urlStr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            loadImage(urlStr: urlStr) { [weak self] img in
                guard let self, let img else { return }
                self.avatarImageView.image = img
                self.avatarImageView.tintColor = .clear
                self.avatarImageView.backgroundColor = .clear
            }
        }

        // optional highlight (بس خفيف)
        if isMe {
            cardView.backgroundColor = UIColor(white: 0.97, alpha: 1)
            cardView.layer.borderColor = UIColor.systemGray2.cgColor
        }
    }

    // MARK: - Setup Card
    private func setupCardView() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        // ✅ المسافات اللي تبينها
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
        ])

        // ✅ بوردر واضح
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 14
        cardView.layer.borderWidth = 1.2
        cardView.layer.borderColor = UIColor.systemGray3.cgColor
        cardView.clipsToBounds = true
    }

    // MARK: - Move storyboard subviews into card
    private func moveSubviewsIntoCard() {
        // إذا كانوا already داخل contentView، ننقلهم
        [rankLabel, avatarImageView, nameLabel, pointsLabel].forEach { v in
            guard let v = v else { return }
            v.removeFromSuperview()
            v.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview(v)
        }

        // ✅ Layout داخل الكارد (مسافات مرتبة)
        NSLayoutConstraint.activate([

            // Rank يسار
            rankLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            rankLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            rankLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 18),

            // Avatar أكبر
            avatarImageView.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 10),
            avatarImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 44),
            avatarImageView.heightAnchor.constraint(equalToConstant: 44),

            // Points يمين
            pointsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            pointsLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            pointsLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 56),

            // Name بالنص
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: pointsLabel.leadingAnchor, constant: -10),
            nameLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
        ])
    }

    // MARK: - Styling
    private func styleLabels() {
        rankLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        rankLabel.textColor = .darkGray
        rankLabel.textAlignment = .left

        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.numberOfLines = 1

        pointsLabel.font = .systemFont(ofSize: 13, weight: .regular)
        pointsLabel.textColor = .darkGray
        pointsLabel.textAlignment = .right
    }

    private func styleAvatar() {
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 22 // لأن 44x44
        avatarImageView.layer.borderWidth = 1.2
        avatarImageView.layer.borderColor = UIColor.systemGray4.cgColor
        avatarImageView.backgroundColor = UIColor.systemGray6

        avatarImageView.tintColor = .systemGray3
        avatarImageView.image = defaultAvatar()
    }

    private func defaultAvatar() -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        return UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
    }

    private func loadImage(urlStr: String, completion: @escaping (UIImage?) -> Void) {
        if let cached = Self.imageCache.object(forKey: urlStr as NSString) {
            completion(cached); return
        }

        guard let url = URL(string: urlStr) else {
            completion(nil); return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data, let img = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            Self.imageCache.setObject(img, forKey: urlStr as NSString)
            DispatchQueue.main.async { completion(img) }
        }.resume()
    }
}
