
import UIKit
import FirebaseAuth
import FirebaseFirestore

private let db = Firestore.firestore()

class DonerDashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Outlets

    // Top boxes (Map, Hub, MyDonation, Goodness, Stats)
    @IBOutlet weak var ngoMapView: UIView!
    @IBOutlet weak var donorHubView: UIView!
    @IBOutlet weak var myDonationView: UIView!
    @IBOutlet weak var goodnessView: UIView!
    @IBOutlet weak var statsView: UIView!

    @IBOutlet weak var tableView: UITableView!
    private var goals: [Goal] = []
    private var goalsListener: ListenerRegistration?
    private var donationsListener: ListenerRegistration?

    @IBOutlet var NotificationsBtn: UIImageView!
    private var donations: [DonationLite] = []
    private var raisedByGoalId: [String: Int] = [:]
    // Spotlight cards (two)
    @IBOutlet weak var spotlightView1: UIView!
    @IBOutlet weak var spotlightView2: UIView!
    @IBOutlet weak var impactRowView: UIView!


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear


        loadGoalsForDashboard()
        startListeningDonationsForDashboard()

        impactRowView.layer.borderWidth = 1
        impactRowView.layer.borderColor = UIColor.systemGray4.cgColor
        impactRowView.layer.cornerRadius = 10
        // TOP BOXES
        styleTopBox(ngoMapView)
        styleTopBox(donorHubView)
        styleTopBox(myDonationView)
        styleTopBox(goodnessView)
        styleTopBox(statsView)

        // SPOTLIGHT (gradient added after layout)
        styleSpotlight(spotlightView1)
        styleSpotlight(spotlightView2)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(goToNotifications))
        NotificationsBtn.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        goalsListener?.remove()
        donationsListener?.remove()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return goals.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "DashboardGoalCardCell",
            for: indexPath
        ) as! DashboardGoalCardCell

        let goal = goals[indexPath.section]
        let raised = raisedByGoalId[goal.id] ?? 0

        cell.configure(with: goal, raised: raised, showDelete: false)
        cell.selectionStyle = .none
        return cell
    }

    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 12   // spacing between cards
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        return UIView() // transparent spacer
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // gradient must be re-applied after the view gets its final size
        styleSpotlight(spotlightView1)
        styleSpotlight(spotlightView2)
    }


    // MARK: - Style Functions

    // Top small boxes
    func styleTopBox(_ view: UIView) {
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.clipsToBounds = true
    }

    // Goal cards (bigger radius)
    func styleGoalCard(_ view: UIView) {
        // Rounded card
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.masksToBounds = true

        // INNER PADDING (this fixes the issue you want)
        view.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        view.preservesSuperviewLayoutMargins = false
    }


    // Spotlight gradient style
    func styleSpotlight(_ view: UIView) {

        // Remove old gradient layers to avoid stacking
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradient = CAGradientLayer()
        gradient.frame = view.bounds

        // Green gradient left → right
        gradient.colors = [
            UIColor(red: 0/255, green: 140/255, blue: 80/255, alpha: 1).cgColor,
            UIColor(red: 0/255, green: 180/255, blue: 100/255, alpha: 1).cgColor
        ]

        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        gradient.cornerRadius = 16

        // Insert gradient at background
        view.layer.insertSublayer(gradient, at: 0)

        view.layer.cornerRadius = 16
        view.clipsToBounds = true
    }
    
    
    @IBAction func DonorRewardsTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "DonorRewards", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "gameViewController")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    @IBAction func DonorRewards2Tapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "DonorRewards", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "gameViewController")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    @IBAction func mapTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "DonorMap", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "DonorMap")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    @IBAction func DonationGroupTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "DonationGroups", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "DonationGroupsVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func DonationTrackingVCTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "DonationTracking", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "DonationTrackingVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    @IBAction func Donate1(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "DonorNGOCases", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "FoodDonationViewController")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func Donate2(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "DonorNGOCases", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "FoodDonationViewController")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func ImpactTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "DonorImpact", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "My_impactViewController")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func LeaderBoardTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Leaderboard", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "LeaderboardViewController")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    private func loadGoalsForDashboard() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        goalsListener = db.collection("users").document(uid).collection("goals")
            .order(by: "startDate", descending: true)
            .addSnapshotListener { [weak self] snap, error in
                guard let self = self else { return }
                if let error = error {
                    print("❌ Load goals error:", error.localizedDescription)
                    return
                }

                let all = (snap?.documents ?? []).compactMap { Goal(doc: $0) }
                self.goals = all.filter { $0.status == "active" }

                self.recalculateRaisedForDashboard()

                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
    
    private func startListeningDonationsForDashboard() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        donationsListener = db.collection("donations")
            .whereField("donorID", isEqualTo: uid) // ✅ matches your Firestore screenshot
            .addSnapshotListener { [weak self] snap, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Load donations error:", error.localizedDescription)
                    return
                }

                self.donations = snap?.documents.compactMap { DonationLite(doc: $0) } ?? []
                self.recalculateRaisedForDashboard()
            }
    }
    
    @objc func goToNotifications() {
        let storyboard = UIStoryboard(name: "DonorNotifications", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "DonorNotificationsVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }


    private func recalculateRaisedForDashboard() {
        var map: [String: Int] = [:]
        let cal = Calendar.current

        for goal in goals {
            let start = cal.startOfDay(for: goal.startDate)
            let end = cal.startOfDay(for: goal.endDate)

            let total = donations.reduce(0) { partial, d in
                let day = cal.startOfDay(for: d.createdAt)
                if day >= start && day <= end {
                    return partial + d.quantity
                }
                return partial
            }

            map[goal.id] = total
        }

        self.raisedByGoalId = map
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

}

private struct DonationLite {
    let quantity: Int
    let createdAt: Date

    init?(doc: QueryDocumentSnapshot) {
        let data = doc.data()

        let qInt = data["quantity"] as? Int
        let qDouble = data["quantity"] as? Double
        let quantity = qInt ?? Int(qDouble ?? 0)

        guard let ts = data["createdAt"] as? Timestamp else { return nil }

        self.quantity = quantity
        self.createdAt = ts.dateValue()
    }
}
