
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

    // Spotlight cards (two)
    @IBOutlet weak var spotlightView1: UIView!
    @IBOutlet weak var spotlightView2: UIView!


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear

        loadGoalsForDashboard()
        
        // TOP BOXES
        styleTopBox(ngoMapView)
        styleTopBox(donorHubView)
        styleTopBox(myDonationView)
        styleTopBox(goodnessView)
        styleTopBox(statsView)

        // SPOTLIGHT (gradient added after layout)
        styleSpotlight(spotlightView1)
        styleSpotlight(spotlightView2)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "DashboardGoalCardCell",
            for: indexPath
        ) as! DashboardGoalCardCell

        cell.configure(with: goals[indexPath.row], showDelete: false)
        return cell
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
        let sb = UIStoryboard(name: "DonorNGOCases", bundle: nil)
        let profileVC = sb.instantiateViewController(withIdentifier: "FoodDonationViewController")

        // replace the placeholder root with the real profile screen
        navigationController?.setViewControllers([profileVC], animated: false)
    }
    
    @IBAction func Donate2(_ sender: UIButton) {
        let sb = UIStoryboard(name: "DonorNGOCases", bundle: nil)
        let profileVC = sb.instantiateViewController(withIdentifier: "FoodDonationViewController")

        // replace the placeholder root with the real profile screen
        navigationController?.setViewControllers([profileVC], animated: false)
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

        db.collection("users").document(uid).collection("goals")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, error in
                guard let self = self else { return }
                if let error = error { print(error.localizedDescription); return }

                let all = (snap?.documents ?? []).compactMap { Goal(doc: $0) }
                self.goals = all.filter { $0.status == "active" }   // local filter
                self.tableView.reloadData()
            }

    }
    
}
