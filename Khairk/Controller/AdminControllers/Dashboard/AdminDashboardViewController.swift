import UIKit
import FirebaseFirestore
import FirebaseAuth

final class AdminDashboardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    private var topNgos: [TopNgoItem] = []
    private var topDonors: [TopDonorItem] = []
    // MARK: - Outlets (نفس اللي عندج)
    @IBOutlet weak var UserAccount: UIView!
    @IBOutlet weak var ManageDonation: UIView!
    @IBOutlet weak var myDonationView: UIView!
    @IBOutlet weak var goodnessView: UIView!
    @IBOutlet weak var statsView: UIView!

    @IBOutlet weak var impactRowView: UIView!

    @IBOutlet weak var topDonorsCV: UICollectionView!
    @IBOutlet weak var topNgosCV: UICollectionView!
    @IBOutlet weak var NotificationsBtn: UIImageView!
    private let db = Firestore.firestore()

    // MARK: - Config
    private let topLimit = 5
    private let maxDonationsToScan = 500

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHorizontalCV(topDonorsCV)
        setupHorizontalCV(topNgosCV)

        topDonorsCV.dataSource = self
        topDonorsCV.delegate = self

        topNgosCV.dataSource = self
        topNgosCV.delegate = self

        loadTopDonors()
        loadTopNgos()
        
        impactRowView.layer.borderWidth = 1
        impactRowView.layer.borderColor = UIColor.systemGray4.cgColor
        impactRowView.layer.cornerRadius = 10
        
        // TOP BOXES (ستايل)
        styleTopBox(UserAccount)
        styleTopBox(ManageDonation)
        styleTopBox(myDonationView)
        styleTopBox(goodnessView)
        styleTopBox(statsView)
        
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(goToAdminNotifications))
        NotificationsBtn.addGestureRecognizer(tapGesture)
    }
    
    private func setupHorizontalCV(_ cv: UICollectionView) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cv.collectionViewLayout = layout
        cv.showsHorizontalScrollIndicator = false
    }

    
    private func loadTopDonors() {
        db.collection("donations")
            .whereField("status", isEqualTo: "accepted")
            .getDocuments(source: .default) { [weak self] snap, error in
                guard let self = self else { return }
                if let error = error {
                    print("❌ donations:", error.localizedDescription)
                    return
                }

                // Parse safely using your Donation model
                let donations = (snap?.documents ?? []).compactMap { Donation(doc: $0) }

                var counts: [String: Int] = [:]

                for donation in donations {
                    let cleanId = donation.donorId.trimmingCharacters(in: .whitespacesAndNewlines)

                    if cleanId.isEmpty {
                        print("⚠️ Donation \(donation.id) has EMPTY donorId")
                        continue
                    }

                    counts[cleanId, default: 0] += 1
                }

                // remove any empty key (extra safety)
                counts.removeValue(forKey: "")

                let top = counts
                    .filter { !$0.key.isEmpty }
                    .sorted { $0.value > $1.value }
                    .prefix(self.topLimit)

                let group = DispatchGroup()
                var result: [TopDonorItem] = []

                for (uid, count) in top {
                    let cleanUid = uid.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !cleanUid.isEmpty else { continue }

                    group.enter()
                    self.db.collection("users").document(cleanUid).getDocument { userSnap, _ in
                        let name = userSnap?.data()?["name"] as? String ?? "Unknown"
                        result.append(TopDonorItem(uid: cleanUid, name: name, count: count))
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    self.topDonors = result.sorted { $0.count > $1.count }
                    self.topDonorsCV.reloadData()
                }
            }
    }

    private func loadTopNgos() {
        db.collection("ngoCases")
            .getDocuments(source: .default) { [weak self] snap, error in
                guard let self = self else { return }
                if let error = error {
                    print("❌ ngoCases:", error.localizedDescription)
                    return
                }

                let cases = (snap?.documents ?? []).compactMap { NgoCase(doc: $0) }

                var counts: [String: Int] = [:]

                for c in cases {
                    // You said ngoID is UID stored in the document field "ngoID"
                    // But NgoCase model doesn’t include ngoID, so we read from doc directly:
                    let d = snap?.documents.first(where: { $0.documentID == c.id })?.data() ?? [:]
                    let ngoIdRaw = d["ngoID"] as? String ?? ""
                    let ngoId = ngoIdRaw.trimmingCharacters(in: .whitespacesAndNewlines)

                    if ngoId.isEmpty { continue }
                    counts[ngoId, default: 0] += 1
                }

                counts.removeValue(forKey: "")

                let top = counts
                    .filter { !$0.key.isEmpty }
                    .sorted { $0.value > $1.value }
                    .prefix(self.topLimit)

                let group = DispatchGroup()
                var result: [TopNgoItem] = []

                for (uid, count) in top {
                    let cleanUid = uid.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !cleanUid.isEmpty else { continue }

                    group.enter()
                    self.db.collection("users").document(cleanUid).getDocument { userSnap, _ in
                        let data = userSnap?.data() ?? [:]
                        let name = data["name"] as? String ?? "NGO"
                        let img = data["profileImageUrl"] as? String
                        result.append(TopNgoItem(uid: cleanUid, name: name, count: count, imageURL: img))
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    self.topNgos = result.sorted { $0.count > $1.count }
                    self.topNgosCV.reloadData()
                }
            }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    // MARK: - Styling (نفس كودج)

    func styleTopBox(_ view: UIView) {
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.clipsToBounds = true
    }

    func styleSpotlight(_ view: UIView) {
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [
            UIColor(red: 0/255, green: 140/255, blue: 80/255, alpha: 1).cgColor,
            UIColor(red: 0/255, green: 180/255, blue: 100/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 16

        view.layer.insertSublayer(gradient, at: 0)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
    }

    // MARK: - Tag Label Setter (بدون Outlets زيادة)
    private func setLabel(in container: UIView, tag: Int, text: String) {
        (container.viewWithTag(tag) as? UILabel)?.text = text
    }
    
    @IBAction func AdminImpactTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AdminImpact", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "AdminCollectorImpact")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    @IBAction func AdminImpact2Tapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "AdminImpact", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "AdminCollectorImpact")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func UserAccountTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "AdminUserManagement", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "UserManagementVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func ManageDonationTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "AdminDonationHistory", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "AdminDonationHistoryVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func Send(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AdminBroadcast", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "AdminBroadcastViewController")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func ProfileTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "AdminProfile", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "AdminProfileVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topDonorsCV { return topDonors.count }
        return topNgos.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if collectionView == topDonorsCV {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopDonorCell", for: indexPath) as! TopDonorCell
            cell.configure(name: topDonors[indexPath.item].name, count: topDonors[indexPath.item].count)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopNgoCell", for: indexPath) as! TopNgoCell
            cell.configure(name: topNgos[indexPath.item].name,
                           count: topNgos[indexPath.item].count,
                           imageURL: topNgos[indexPath.item].imageURL)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let h = collectionView.bounds.height

        if collectionView == topDonorsCV {
            // card fits inside 120 height CV
            return CGSize(width: 165, height: 75)
        } else {
            // bigger card for NGO
            return CGSize(width: 135, height: 166)
        }
    }
    
    @objc func goToAdminNotifications() {
        let storyboard = UIStoryboard(name: "AdminNotifications", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "AdminNotificationVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }


}

struct TopDonorItem {
    let uid: String
    let name: String
    let count: Int
}

struct TopNgoItem {
    let uid: String
    let name: String
    let count: Int
    let imageURL: String?
}

