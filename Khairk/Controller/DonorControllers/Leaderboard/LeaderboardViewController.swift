import UIKit
import FirebaseFirestore
import FirebaseAuth

// ✅ استخدمنا اسم مختلف عشان ما يصير Ambiguous
struct LBUser {
    let userId: String
    let name: String
    let points: Double
    let profileImageUrl: String?
}

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

    @IBOutlet weak var firstCrownImageView: UIImageView!

    // MARK: - Data
    private let db = Firestore.firestore()

    // ✅ Top 3 منفصلين عشان نقل "You" ما يخربهم
    private var topThree: [LBUser] = []

    // ✅ هذي حق الجدول (بعد Top 3)
    private var users: [LBUser] = []

    // MARK: - Image Cache
    private static let imageCache = NSCache<NSString, UIImage>()

    // MARK: - My rank label
    private let myRankLabel = UILabel()

    // MARK: - Crown constraints
    private var crownCenterX: NSLayoutConstraint?
    private var crownBottom: NSLayoutConstraint?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Leaderboard"
        navigationItem.largeTitleDisplayMode = .never

        setupTable()
        setupMyRankHeader()

        applyStyle()
        enforceSquareTopImages()

        showEmpty()
        loadLeaderboard()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        [firstImage, secondImage, thirdImage].forEach { img in
            guard let img = img else { return }
            let side = min(img.bounds.width, img.bounds.height)
            img.layer.cornerRadius = side / 2
            img.clipsToBounds = true
        }

        positionCrownAboveWinner()
    }

    // MARK: - Table
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }

    private func setupMyRankHeader() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 52))
        header.backgroundColor = .clear

        myRankLabel.frame = CGRect(x: 16, y: 10, width: tableView.bounds.width - 32, height: 32)
        myRankLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        myRankLabel.textColor = .darkGray
        myRankLabel.textAlignment = .left
        myRankLabel.text = ""

        header.addSubview(myRankLabel)
        tableView.tableHeaderView = header
    }

    // MARK: - Style
    private func applyStyle() {
        let green = UIColor(red: 0/255, green: 110/255, blue: 60/255, alpha: 1)

        view.backgroundColor = .systemBackground

        TopThreeContainer.backgroundColor = .white
        TopThreeContainer.layer.cornerRadius = 28
        TopThreeContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        TopThreeContainer.clipsToBounds = true

        tableView.backgroundColor = .systemGray6
        tableView.layer.cornerRadius = 28
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.clipsToBounds = true

        [firstImage, secondImage, thirdImage].forEach { img in
            img?.contentMode = .scaleAspectFill
            img?.clipsToBounds = true
            img?.layer.borderWidth = 2.5
            img?.layer.borderColor = green.cgColor
            img?.backgroundColor = .white
            img?.image = defaultAvatar()
            img?.tintColor = .systemGray2
        }

        firstCrownImageView.contentMode = .scaleAspectFit
        firstCrownImageView.isHidden = true

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
        return UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
    }

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
        topThree = [
            LBUser(userId: "p1", name: "No data yet", points: 0.0, profileImageUrl: nil),
            LBUser(userId: "p2", name: "No data yet", points: 0.0, profileImageUrl: nil),
            LBUser(userId: "p3", name: "No data yet", points: 0.0, profileImageUrl: nil)
        ]
        users = [
            LBUser(userId: "p4", name: "No more users yet", points: 0.0, profileImageUrl: nil)
        ]

        updateTop3()
        updateMyRankLabel(fullSortedAll: topThree + users)
        tableView.reloadData()
    }

    // MARK: - Top3 UI (winner in center)
    private func updateTop3() {

        func set(_ user: LBUser?,
                 imgView: UIImageView,
                 nameLabel: UILabel,
                 pointsLabel: UILabel) {

            nameLabel.text = user?.name ?? "No data yet"
            pointsLabel.text = String(format: "%.1f pts", user?.points ?? 0.0)

            imgView.image = defaultAvatar()
            imgView.tintColor = .systemGray2

            if let urlStr = user?.profileImageUrl, !urlStr.isEmpty {
                loadImage(urlStr: urlStr) { image in
                    if let image = image {
                        imgView.image = image
                        imgView.tintColor = .clear
                    }
                }
            }
        }

        let first  = topThree.indices.contains(0) ? topThree[0] : nil
        let second = topThree.indices.contains(1) ? topThree[1] : nil
        let third  = topThree.indices.contains(2) ? topThree[2] : nil

        // الوسط = secondImage
        set(first,  imgView: secondImage, nameLabel: secondName, pointsLabel: secondPoints)
        set(second, imgView: firstImage,  nameLabel: firstName,  pointsLabel: firstPoints)
        set(third,  imgView: thirdImage,  nameLabel: thirdName,  pointsLabel: thirdPoints)

        firstCrownImageView.isHidden = !((first?.points ?? 0.0) > 0.0)
        positionCrownAboveWinner()
    }

    private func positionCrownAboveWinner() {
        firstCrownImageView.translatesAutoresizingMaskIntoConstraints = false

        crownCenterX?.isActive = false
        crownBottom?.isActive = false

        crownCenterX = firstCrownImageView.centerXAnchor.constraint(equalTo: secondImage.centerXAnchor)
        crownBottom  = firstCrownImageView.bottomAnchor.constraint(equalTo: secondImage.topAnchor, constant: -6)

        NSLayoutConstraint.activate([
            crownCenterX!,
            crownBottom!,
            firstCrownImageView.widthAnchor.constraint(equalToConstant: 26),
            firstCrownImageView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }

    // ✅ My rank ينحسب من Full Sorted (قبل نقل You)
    private func updateMyRankLabel(fullSortedAll: [LBUser]) {
        guard let myId = Auth.auth().currentUser?.uid else {
            myRankLabel.text = "Your rank: —"
            return
        }

        if let idx = fullSortedAll.firstIndex(where: { $0.userId == myId }) {
            myRankLabel.text = "Your rank: #\(idx + 1) of \(fullSortedAll.count)"
        } else {
            myRankLabel.text = "Your rank: not ranked yet"
        }
    }

    // MARK: - Image Loader
    private func loadImage(urlStr: String, completion: @escaping (UIImage?) -> Void) {

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

        db.collection("donations").getDocuments { [weak self] donationSnap, err in
            guard let self else { return }

            if let err = err {
                print("❌ donations error:", err)
                self.showEmpty()
                return
            }

            var pointsByDonor: [String: Double] = [:]

            donationSnap?.documents.forEach { doc in
                let donorId = doc.data()["donorId"] as? String ?? ""
                if !donorId.isEmpty {
                    pointsByDonor[donorId, default: 0.0] += 0.5
                }
            }

            self.fetchAllDonorUsers(pointsByDonor: pointsByDonor)
        }
    }

    private func fetchAllDonorUsers(pointsByDonor: [String: Double]) {

        db.collection("users")
            .whereField("role", isEqualTo: "donor")
            .getDocuments { [weak self] userSnap, err in
                guard let self else { return }

                if let err = err {
                    print("❌ users error:", err)
                    self.showEmpty()
                    return
                }

                var temp: [LBUser] = []

                for doc in userSnap?.documents ?? [] {
                    let d = doc.data()
                    let uid = doc.documentID

                    let name = d["name"] as? String ?? "Unknown"
                    let imgUrl = d["profileImageUrl"] as? String

                    let pts = pointsByDonor[uid] ?? 0.0
                    temp.append(LBUser(userId: uid, name: name, points: pts, profileImageUrl: imgUrl))
                }

                // ✅ 1) ترتيب كامل حقيقي
                let fullSorted = temp.sorted { $0.points > $1.points }

                // ✅ 2) Top 3 الحقيقيين
                self.topThree = Array(fullSorted.prefix(3))

                // ✅ 3) باقي الناس للجدول
                var rest = Array(fullSorted.dropFirst(3))

                // ✅ 4) نقل اليوزر الحالي للنهاية + اسم You (في الجدول فقط)
                if let myId = Auth.auth().currentUser?.uid,
                   let idx = rest.firstIndex(where: { $0.userId == myId }) {

                    var me = rest.remove(at: idx)
                    me = LBUser(userId: me.userId, name: "You", points: me.points, profileImageUrl: me.profileImageUrl)
                    rest.append(me)
                }

                // ✅ placeholders
                while self.topThree.count < 3 {
                    self.topThree.append(LBUser(userId: "pX", name: "No data yet", points: 0.0, profileImageUrl: nil))
                }
                if rest.isEmpty {
                    rest = [LBUser(userId: "p4", name: "No more users yet", points: 0.0, profileImageUrl: nil)]
                }

                self.users = rest

                self.updateTop3()
                self.updateMyRankLabel(fullSortedAll: fullSorted)
                self.tableView.reloadData()
            }
    }
}

// MARK: - TableView
extension LeaderboardViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardRowCell", for: indexPath) as! LeaderboardRowCell

        let user = users[indexPath.row]
        let rank = indexPath.row + 4

        let myId = Auth.auth().currentUser?.uid
        let isMe = (user.userId == myId)

        cell.configure(rank: rank, user: user, isMe: isMe)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
