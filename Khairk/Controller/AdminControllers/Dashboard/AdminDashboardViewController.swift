import UIKit
import FirebaseFirestore

final class AdminDashboardViewController: UIViewController {

    // MARK: - Outlets (نفس اللي عندج)
    @IBOutlet weak var UserAccount: UIView!
    @IBOutlet weak var ManageDonation: UIView!
    @IBOutlet weak var myDonationView: UIView!
    @IBOutlet weak var goodnessView: UIView!
    @IBOutlet weak var statsView: UIView!

    @IBOutlet weak var goalCard1: UIView!
    @IBOutlet weak var goalCard2: UIView!

    @IBOutlet weak var spotlightView1: UIView!
    @IBOutlet weak var spotlightView2: UIView!

    // MARK: - Firestore
    private let db = Firestore.firestore()

    // MARK: - Config
    private let topLimit = 5
    private let maxDonationsToScan = 500

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Admin Dashboard"

        // TOP BOXES (ستايل)
        styleTopBox(UserAccount)
        styleTopBox(ManageDonation)
        styleTopBox(ManageDonation)
        styleTopBox(goodnessView)
        styleTopBox(statsView)

        // GOAL CARDS
        styleGoalCard(goalCard1)
        styleGoalCard(goalCard2)

        // SPOTLIGHT
        styleSpotlight(spotlightView1)
        styleSpotlight(spotlightView2)

        // Default texts (قبل الداتا)
        setLabel(in: goalCard1, tag: 101, text: "Total Donations")
        setLabel(in: goalCard1, tag: 102, text: "—")

        setLabel(in: goalCard2, tag: 111, text: "Total Users")
        setLabel(in: goalCard2, tag: 112, text: "—")

        setLabel(in: spotlightView1, tag: 201, text: "Top Donor")
        setLabel(in: spotlightView1, tag: 202, text: "Loading…")

        setLabel(in: spotlightView2, tag: 211, text: "Top NGO")
        setLabel(in: spotlightView2, tag: 212, text: "Loading…")

        // Retrieve
        loadAdminStats()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // gradient لازم بعد ما ياخذ الحجم النهائي
        styleSpotlight(spotlightView1)
        styleSpotlight(spotlightView2)
    }

    // MARK: - Retrieve (Admin Dashboard)
    private func loadAdminStats() {
        fetchTotals()
        fetchTopDonorAndTopNGO()
    }

    private func fetchTotals() {
        // Total Donations
        db.collection("donations").getDocuments { [weak self] snap, _ in
            guard let self else { return }
            self.setLabel(in: self.goalCard1, tag: 102, text: "\(snap?.count ?? 0)")
        }

        // Total Users
        db.collection("users").getDocuments { [weak self] snap, _ in
            guard let self else { return }
            self.setLabel(in: self.goalCard2, tag: 112, text: "\(snap?.count ?? 0)")
        }

        // إذا تبين Total NGOs بدل Total Users:
        // db.collection("ngos").getDocuments { [weak self] snap, _ in
        //   self?.setLabel(in: self!.goalCard2, tag: 112, text: "\(snap?.count ?? 0)")
        //   self?.setLabel(in: self!.goalCard2, tag: 111, text: "Total NGOs")
        // }
    }

    private func fetchTopDonorAndTopNGO() {

        db.collection("donations")
            .order(by: "createdAt", descending: true)
            .limit(to: maxDonationsToScan)
            .getDocuments { [weak self] snap, err in
                guard let self else { return }

                if let err = err {
                    print("❌ donations error:", err)
                    self.setLabel(in: self.spotlightView1, tag: 202, text: "Error")
                    self.setLabel(in: self.spotlightView2, tag: 212, text: "Error")
                    return
                }

                let docs = snap?.documents ?? []
                if docs.isEmpty {
                    self.setLabel(in: self.spotlightView1, tag: 202, text: "No data")
                    self.setLabel(in: self.spotlightView2, tag: 212, text: "No data")
                    return
                }

                // 1) Count donations per donorId
                var donorCount: [String: Int] = [:]
                // 2) collect caseIds for NGO mapping
                var caseIds: [String] = []

                for d in docs {
                    let data = d.data()

                    if let donorId = data["donorId"] as? String, !donorId.isEmpty {
                        donorCount[donorId, default: 0] += 1
                    }
                    if let caseId = data["caseId"] as? String, !caseId.isEmpty {
                        caseIds.append(caseId)
                    }
                }

                // Top Donor (single)
                if let topDonor = donorCount.max(by: { $0.value < $1.value }) {
                    self.fetchUserName(userId: topDonor.key) { name in
                        self.setLabel(in: self.spotlightView1, tag: 201, text: "Top Donor")
                        self.setLabel(in: self.spotlightView1, tag: 202, text: "\(name) • \(topDonor.value) donations")
                    }
                } else {
                    self.setLabel(in: self.spotlightView1, tag: 202, text: "No donors")
                }

                // Top NGO:
                // donations.caseId -> ngoCases(caseId).ngoID -> count by ngoID -> ngos(ngoID).name
                self.fetchNgoIDsFromCaseIDs(caseIds: Array(Set(caseIds))) { caseToNgo in

                    var ngoCount: [String: Int] = [:]
                    for d in docs {
                        let data = d.data()
                        guard let caseId = data["caseId"] as? String else { continue }
                        if let ngoID = caseToNgo[caseId], !ngoID.isEmpty {
                            ngoCount[ngoID, default: 0] += 1
                        }
                    }

                    guard let topNgo = ngoCount.max(by: { $0.value < $1.value }) else {
                        self.setLabel(in: self.spotlightView2, tag: 212, text: "No NGOs")
                        return
                    }

                    self.fetchNgoName(ngoId: topNgo.key) { ngoName in
                        self.setLabel(in: self.spotlightView2, tag: 211, text: "Top NGO")
                        self.setLabel(in: self.spotlightView2, tag: 212, text: "\(ngoName) • \(topNgo.value) donations")
                    }
                }
            }
    }

    // MARK: - Helpers (Firestore)

    private func fetchUserName(userId: String, completion: @escaping (String) -> Void) {
        db.collection("users").document(userId).getDocument { snap, _ in
            let name = (snap?["name"] as? String) ?? (snap?["fullName"] as? String) ?? "Unknown"
            completion(name)
        }
    }

    private func fetchNgoName(ngoId: String, completion: @escaping (String) -> Void) {
        db.collection("ngos").document(ngoId).getDocument { snap, _ in
            let name = (snap?["name"] as? String) ?? "Unknown NGO"
            completion(name)
        }
    }

    private func fetchNgoIDsFromCaseIDs(caseIds: [String], completion: @escaping ([String: String]) -> Void) {
        guard !caseIds.isEmpty else { completion([:]); return }

        // Firestore whereIn max 10
        let batches = caseIds.chunked(into: 10)
        var result: [String: String] = [:]
        let group = DispatchGroup()

        for batch in batches {
            group.enter()
            db.collection("ngoCases")
                .whereField(FieldPath.documentID(), in: batch)
                .getDocuments { snap, err in
                    defer { group.leave() }
                    if let err = err {
                        print("❌ ngoCases error:", err)
                        return
                    }
                    for doc in snap?.documents ?? [] {
                        let data = doc.data()
                        if let ngoID = data["ngoID"] as? String {
                            result[doc.documentID] = ngoID
                        }
                    }
                }
        }

        group.notify(queue: .main) { completion(result) }
    }

    // MARK: - Styling (نفس كودج)

    func styleTopBox(_ view: UIView) {
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.clipsToBounds = true
    }

    func styleGoalCard(_ view: UIView) {
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.masksToBounds = true

        view.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        view.preservesSuperviewLayoutMargins = false
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
}

// MARK: - Array chunk helper
private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        var result: [[Element]] = []
        var i = 0
        while i < count {
            let end = Swift.min(i + size, count)
            result.append(Array(self[i..<end]))
            i += size
        }
        return result
    }
}
