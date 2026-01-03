//
//  ViewGoalsViewController.swift
//  Khairk
//
//  Created by vkc5 on 19/12/2025.
//
import Foundation
import FirebaseFirestore
import UIKit
import FirebaseAuth

class ViewGoalsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    
    private var donations: [DonationLite] = []
    private var donationsListener: ListenerRegistration?
    private var raisedByGoalId: [String: Int] = [:]

    private let db = Firestore.firestore()
    private var goals: [Goal] = []
    private var listener: ListenerRegistration?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear

        startListeningGoals()
        startListeningDonations()   // ✅ add this
    }

    deinit {
        listener?.remove()
        donationsListener?.remove()
    }


    private func startListeningGoals() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ Not logged in")
            return
        }

        listener = db.collection("users").document(uid).collection("goals")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snap, error in
                if let error = error {
                    print("❌ Load goals error:", error.localizedDescription)
                    return
                }

                self?.goals = snap?.documents.compactMap { Goal(doc: $0) } ?? []
                self?.recalculateRaised()
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
    }

    private func confirmDelete(goal: Goal) {
        let alert = UIAlertController(
            title: "Delete Goal?",
            message: "Are you sure you want to delete this goal?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteGoal(goalId: goal.id)
        })

        present(alert, animated: true)
    }

    private func deleteGoal(goalId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(uid).collection("goals").document(goalId).delete { error in
            if let error = error {
                print("❌ Delete failed:", error.localizedDescription)
            } else {
                print("✅ Goal deleted:", goalId)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return goals.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 6   // 👈 spacing between cells
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        let cell = tableView.dequeueReusableCell(
            withIdentifier: "GoalCardCell",
            for: indexPath
        ) as! GoalCardCellTableViewCell

        let goal = goals[indexPath.section]
        let raised = raisedByGoalId[goal.id] ?? 0
        cell.configure(goal: goal, raised: raised)

        cell.onDeleteTapped = { [weak self] in
            self?.confirmDelete(goal: goal)
        }

        cell.selectionStyle = .none
        return cell
    }
    
    private func startListeningDonations() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        donationsListener = db.collection("donations")
            .whereField("donorID", isEqualTo: uid) // ✅ use EXACT field name from Firestore (your screenshot shows donorID)
            .addSnapshotListener { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err {
                    print("❌ Load donations error:", err.localizedDescription)
                    return
                }

                self.donations = snap?.documents.compactMap { DonationLite(doc: $0) } ?? []
                self.recalculateRaised()
            }
    }
    
    private func recalculateRaised() {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

private struct DonationLite {
    let quantity: Int
    let createdAt: Date

    init?(doc: QueryDocumentSnapshot) {
        let data = doc.data()

        // quantity might be Int or Double in Firestore
        let qInt = data["quantity"] as? Int
        let qDouble = data["quantity"] as? Double
        let quantity = qInt ?? Int(qDouble ?? 0)

        guard let ts = data["createdAt"] as? Timestamp else { return nil }

        self.quantity = quantity
        self.createdAt = ts.dateValue()
    }
}

