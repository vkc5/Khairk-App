//
//  FoodDonationViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 20/12/2025.
//

import UIKit
import FirebaseFirestore

class FoodDonationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    struct NgoCase {
        var id: String
        var title: String
        var ngoId: String      // ✅ add this
        var description: String
        var goal: Double
        var currentRaised: Double
        var imageURL: String
        var endDate: Date
        var name: String
        var createdAt: Date

        // Status logic based on your specific requirements
        var statusText: String {
            let now = Date() // Today: Jan 2, 2026
            let calendar = Calendar.current
            
            let achievementRatio = goal > 0 ? (currentRaised / goal) : 0
            let daysUntilEnd = calendar.dateComponents([.day], from: now, to: endDate).day ?? 0
            let totalDuration = calendar.dateComponents([.day], from: createdAt, to: endDate).day ?? 1
            let daysPassed = calendar.dateComponents([.day], from: createdAt, to: now).day ?? 0

            // 1. Expiring soon: Goal >= 86% OR days left < 10
            if achievementRatio >= 0.86 || daysUntilEnd < 10 {
                return "Expiring soon"
            }
            
            // 2. Expiring: Half duration passed OR Goal >= 75%
            if daysPassed >= (totalDuration / 2) || achievementRatio >= 0.75 {
                return "Expiring"
            }
            
            // 3. New: Added within last 7 days
            let daysSinceCreated = calendar.dateComponents([.day], from: createdAt, to: now).day ?? 0
            if daysSinceCreated <= 7 {
                return "New"
            }
            
            return "Active"
        }
        
        // Logical check to hide completed or past-due campaigns
        var isCompletedOrExpired: Bool {
            let now = Date()
            return currentRaised >= goal || now > endDate
        }
    }
    
    var allCases: [NgoCase] = []      // Original data from Firebase
    var casesList: [NgoCase] = []     // Data currently shown (filtered/searched)
    let db = Firestore.firestore()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        setupFilterGesture()
        fetchCases()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 400
    }

    private func setupSearchBar() {
        searchBar?.delegate = self
        searchBar?.placeholder = "Search by campaign or NGO..."
    }

    private func setupFilterGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(filterTapped))
        filterImageView?.isUserInteractionEnabled = true
        filterImageView?.addGestureRecognizer(tapGesture)
    }

    // MARK: - Search Logic
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            casesList = allCases
        } else {
            casesList = allCases.filter { item in
                item.title.lowercased().contains(searchText.lowercased()) ||
                item.name.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // MARK: - Firebase Data Fetching
    private func fetchCases() {
        db.collection("ngoCases").addSnapshotListener { [weak self] querySnapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }
            
            var fetchedCases: [NgoCase] = []
            for document in querySnapshot?.documents ?? [] {
                let data = document.data()
                let item = NgoCase(
                    id: document.documentID,
                    title: data["title"] as? String ?? "",
                    ngoId: data["ngoID"] as? String ?? "",
                    description: data["description"] as? String ?? "",
                    goal: data["Goal"] as? Double ?? 0.0,
                    currentRaised: data["raisedAmount"] as? Double ?? 0.0,
                    imageURL: data["imageURL"] as? String ?? "",
                    endDate: (data["endDate"] as? Timestamp)?.dateValue() ?? Date(),
                    name: data["name"] as? String ?? "",
                    createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                )

                
                // Only add campaigns that are NOT completed and NOT expired
                if !item.isCompletedOrExpired {
                    fetchedCases.append(item)
                }
            }
            self.allCases = fetchedCases
            self.casesList = fetchedCases
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }

    // MARK: - Filter Logic
    @objc private func filterTapped() {
        let alert = UIAlertController(title: "Filter Cases", message: "Choose a category", preferredStyle: .actionSheet)
        let filters = ["All", "New", "Expiring", "Expiring soon"]
        
        for filter in filters {
            alert.addAction(UIAlertAction(title: filter, style: .default) { _ in
                if filter == "All" {
                    self.casesList = self.allCases
                } else {
                    self.casesList = self.allCases.filter { $0.statusText == filter }
                }
                self.tableView.reloadData()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Support for iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = filterImageView
            popover.sourceRect = filterImageView.bounds
        }
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8   // 👈 space between rows (adjust as you like)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }

    // MARK: - TableView DataSource & Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return casesList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell", for: indexPath) as! FoodCaseTableViewCell
        let caseData = casesList[indexPath.section]
        
        // 1. Basic Info
        cell.caseNameLabel?.text = caseData.title
        cell.descriptionLabel?.text = caseData.description
        cell.ngoNameLabel?.text = caseData.name
        cell.statsLabel?.text = caseData.statusText
        
        // 2. Progress & Percentage Calculation
        if caseData.goal > 0 {
            let ratio = Float(caseData.currentRaised / caseData.goal)
            cell.progressBar.progress = ratio
            cell.percentageLabel.text = "\(Int(ratio * 100))%"
        }

        // 3. Days Remaining Calculation
        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: caseData.endDate).day ?? 0
        cell.daysLeftLabel?.text = "\(max(0, daysLeft))"
        
        // 4. Set Status Color
        switch caseData.statusText {
        case "Expiring soon":
            cell.statsLabel?.textColor = .systemRed
        case "Expiring":
            cell.statsLabel?.textColor = .systemOrange
        case "New":
            cell.statsLabel?.textColor = .systemBlue
        default:
            cell.statsLabel?.textColor = .systemGreen
        }

        // 5. Navigation Closure
        cell.onViewDetailsTapped = { [weak self] in
            self?.performSegue(withIdentifier: "ShowDetails", sender: caseData)
        }
        
        // 6. Async Image Loading
        if let url = URL(string: caseData.imageURL) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async { cell.caseImageView.image = UIImage(data: data) }
                }
            }.resume()
        }
        
        return cell
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetails",
           let destinationVC = segue.destination as? FoodCaseViewController,
           let caseToPass = sender as? NgoCase {
            destinationVC.selectedCase = caseToPass
        }
        if segue.identifier == "ShowDonationForm",
           let vc = segue.destination as? DonationFormViewController,
           let c = sender as? NgoCase {

            vc.caseId = c.id
            vc.ngoId  = c.ngoId
        }
    }
}
