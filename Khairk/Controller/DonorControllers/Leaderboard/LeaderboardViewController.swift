import UIKit
import FirebaseFirestore

final class LeaderboardViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var TopThreeContainer: UIView!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var firstPoints: UILabel!

    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var secondName: UILabel!
    @IBOutlet weak var secondPoints: UILabel!

    @IBOutlet weak var thirdImage: UIImageView!
    @IBOutlet weak var thirdName: UILabel!
    @IBOutlet weak var thirdPoints: UILabel!

    // 👑 تاج التوب 1 من الستوري بورد
    @IBOutlet weak var firstCrownImageView: UIImageView!

    // MARK: - Data
    private let db = Firestore.firestore()
    private var users: [LeaderboardUser] = []

    // MARK: - Simple Image Cache
    private static let imageCache = NSCache<NSString, UIImage>()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Leaderboard"
        navigationItem.largeTitleDisplayMode = .never

        setupTable()
        applyStyle()
        enforceSquareTopImages()

        showEmpty()
        loadLeaderboard()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // دايرة 100%
        [firstImage, secondImage, thirdImage].forEach { img in
            guard let img = img else { return }
            let side = min(img.bounds.width, img.bounds.height)
            img.layer.cornerRadius = side / 2
            img.clipsToBounds = true
        }
    }

    // MARK: - Table
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }

    // MARK: - Style
    private func applyStyle() {
        let green = UIColor(red: 0/255, green: 110/255, blue: 60/255, alpha: 1)

        view.backgroundColor = .systemBackground

        // فوق أبيض
        TopThreeContainer.backgroundColor = .white
        TopThreeContainer.layer.cornerRadius = 28
        TopThreeContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        TopThreeContainer.clipsToBounds = true

        // تحت رصاصي خفيف
        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 28
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.clipsToBounds = true

        // صور Top 3
        [firstImage, secondImage, thirdImage].forEach { img in
            img?.contentMode = .scaleAspectFill
            img?.clipsToBounds = true
            img?.layer.borderWidth = 2.5
            img?.layer.borderColor = green.cgColor
            img?.backgroundColor = .white

            // ✅ مهم: لو ما فيه صورة، حط placeholder عشان ما يطلع فاضي
            img?.image = defaultAvatar()
        }

        // التاج من الستوربورد
        firstCrownImageView.contentMode = .scaleAspectFit
        firstCrownImageView.isHidden = true

        // Labels
        [firstName, secondName, thirdName].forEach { lbl in
            lbl?.font = .systemFont(ofSize: 14, weight: .semibold)
            lbl?.textAlignment = .center
            lbl?.numberOfLines = 1
            lbl?.adjustsFontSizeToFitWidth = true
            lbl?.minimumScaleFactor = 0.75
            lbl?.lineBreakMode = .byTruncatingTail
            lbl?.textColor = .black
        }

        [firstPoints, secondPoints, thirdPoints].forEach { lbl in
            lbl?.font = .systemFont(ofSize: 13, weight: .regular)
            lbl?.textAlignment = .center
            lbl?.textColor = .darkGray
        }

        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 16, right: 0)
    }

    private func defaultAvatar() -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .regular)
        let img = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
        return img
    }

    // MARK: - Force square (عشان تطلع دايرة)
    private func enforceSquareTopImages() {
        [firstImage, secondImage, thirdImage].forEach { img in
            guard let img = img else { return }
            img.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                img.widthAnchor.constraint(equalTo: img.heightAnchor)
            ])
        }
    }

    // MARK: - Empty
    private func showEmpty() {
        users = [
            LeaderboardUser(userId: "p1", name: "No data yet", points: 0.0, profileImageUrl: nil),
            LeaderboardUser(userId: "p2", name: "No data yet", points: 0.0, profileImageUrl: nil),
            LeaderboardUser(userId: "p3", name: "No data yet", points: 0.0, profileImageUrl: nil),
            LeaderboardUser(userId: "p4", name: "No users yet — add a donation", points: 0.0, profileImageUrl: nil)
        ]
        updateTop3()
        tableView.reloadData()
    }

    // MARK: - Top3 UI
    private func updateTop3() {
        func set(_ user: LeaderboardUser?,
                 imgView: UIImageView,
                 nameLabel: UILabel,
                 pointsLabel: UILabel) {

            nameLabel.text = user?.name ?? "No data yet"
            pointsLabel.text = String(format: "%.1f pts", user?.points ?? 0.0)

            // ✅ always keep placeholder first (so it never looks empty)
            imgView.image = defaultAvatar()
            imgView.tintColor = .systemGray2

            // ✅ load real image if exists
            if let urlStr = user?.profileImageUrl, !urlStr.isEmpty {
                loadImage(urlStr: urlStr) { image in
                    if let image = image {
                        imgView.image = image
                        imgView.tintColor = .clear
                    }
                }
            }
        }

        set(users.indices.contains(0) ? users[0] : nil, imgView: firstImage,  nameLabel: firstName,  pointsLabel: firstPoints)
        set(users.indices.contains(1) ? users[1] : nil, imgView: secondImage, nameLabel: secondName, pointsLabel: secondPoints)
        set(users.indices.contains(2) ? users[2] : nil, imgView: thirdImage,  nameLabel: thirdName,  pointsLabel: thirdPoints)

        // 👑 التاج يظهر بس إذا فعلاً فيه متصدر
        firstCrownImageView.isHidden = !(users.indices.contains(0) && users[0].points > 0.0)
    }

    // MARK: - Image Loader (URL)
    private func loadImage(urlStr: String, completion: @escaping (UIImage?) -> Void) {

        // Cache first
        if let cached = Self.imageCache.object(forKey: urlStr as NSString) {
            DispatchQueue.main.async { completion(cached) }
            return
        }

        guard let url = URL(string: urlStr) else {
            DispatchQueue.main.async { completion(nil) }
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let img = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            Self.imageCache.setObject(img, forKey: urlStr as NSString)
            DispatchQueue.main.async { completion(img) }
        }.resume()
    }

    // MARK: - Firebase
    private func loadLeaderboard() {
        db.collection("donations").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ donations error:", error)
                return
            }

            var pointsByDonor: [String: Double] = [:]

            snapshot?.documents.forEach { doc in
                let donorId = doc.data()["donorId"] as? String ?? ""
                if !donorId.isEmpty {
                    pointsByDonor[donorId, default: 0.0] += 0.5
                }
            }

            if pointsByDonor.isEmpty { return }
            self.fetchUsers(pointsByDonor: pointsByDonor)
        }
    }

    private func fetchUsers(pointsByDonor: [String: Double]) {
        let group = DispatchGroup()
        var temp: [LeaderboardUser] = []

        for (uid, pts) in pointsByDonor {
            group.enter()
            db.collection("users").document(uid).getDocument { doc, _ in
                let data = doc?.data()
                let name = data?["name"] as? String ?? "Unknown"
                let imgUrl = data?["profileImageUrl"] as? String
                temp.append(LeaderboardUser(userId: uid, name: name, points: pts, profileImageUrl: imgUrl))
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.users = temp.sorted { $0.points > $1.points }

            if self.users.count <= 3 {
                self.users.append(LeaderboardUser(userId: "p4", name: "No more users yet", points: 0.0, profileImageUrl: nil))
            }

            self.updateTop3()
            self.tableView.reloadData()
        }
    }
}

// MARK: - TableView
extension LeaderboardViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(users.count - 3, 0)
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardRowCell", for: indexPath) as! LeaderboardRowCell
        let user = users[indexPath.row + 3]
        let rank = indexPath.row + 4
        cell.configure(rank: rank, user: user)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
