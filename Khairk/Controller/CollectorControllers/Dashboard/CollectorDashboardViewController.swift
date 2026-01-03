//
//  CollectorDashboardViewController.swift
//  Khairk
//
//  Created by Ghaida Buhmaid on 15/12/2025.

 

import UIKit
import FirebaseAuth
import FirebaseFirestore

private let db = Firestore.firestore()

class CollectorDashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Outlets

    // Top boxes (Mycase, Acceptdonation, Mypickup, Stats)
    @IBOutlet weak var Mycase: UIView!
    @IBOutlet weak var Acceptdonation: UIView!
    @IBOutlet weak var Mypickup: UIView!
    @IBOutlet weak var statsView: UIView!
    @IBOutlet weak var ProfileView: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var cases: [NgoCase] = []

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

        loadCasesForCollectorDashboard()

        
        impactRowView.layer.borderWidth = 1
        impactRowView.layer.borderColor = UIColor.systemGray4.cgColor
        impactRowView.layer.cornerRadius = 10

        // TOP BOXES
        styleTopBox(Mycase)
        styleTopBox(Acceptdonation)
        styleTopBox(Mypickup)
        styleTopBox(statsView)
        styleTopBox(ProfileView)

        styleSpotlight(spotlightView1)
        styleSpotlight(spotlightView2)
    }
    
    // spacing method (sections)
    func numberOfSections(in tableView: UITableView) -> Int { cases.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "CollectorCaseCardCell",
            for: indexPath
        ) as! CollectorCaseCardCell

        cell.configure(with: cases[indexPath.section])
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 12 }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { UIView() }

    private func loadCasesForCollectorDashboard() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("ngoCases")
            .whereField("ngoID", isEqualTo: uid)       // ✅ belongs to this NGO
            .addSnapshotListener { [weak self] snap, error in
                guard let self else { return }

                if let error = error {
                    print("❌ Load cases error:", error.localizedDescription)
                    return
                }

                let all = (snap?.documents ?? []).compactMap { NgoCase(doc: $0) }

                // ✅ optional: keep active only
                self.cases = all.filter { $0.status == "active" }

                // ✅ sort locally (avoid composite index)
                self.cases.sort { $0.startDate > $1.startDate }

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
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
    
    @IBAction func Add1(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "NGOCasesManagement", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "MyCasesVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func Add2(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "NGOCasesManagement", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "MyCasesVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func ProfileTapped(_ sender: UIButton) {        
        let storyboard = UIStoryboard(name: "CollectorProfile", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "CollectorProfileVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)

    }
    
    @IBAction func ImpactTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "CollectorImpact", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "My_impactViewController")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func ImpactTapped2(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CollectorImpact", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "My_impactViewController")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func AddCaseTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "NGOCasesManagement", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "MyCasesVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func MyPickup(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "CollectorPickupHistory", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "CollectorPickupHistoryController")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    @IBAction func AcceptDonationtapped(_ sender: UIButton) {
        openAcceptsDonations()
    }
    
    func openAcceptsDonations() {
        let vc = NGOAcceptsDonationViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    
}
