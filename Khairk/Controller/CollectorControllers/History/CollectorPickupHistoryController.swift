//
//  CollectorPickupHistoryController.swift
//  Khairk
//
//  Created by BP-36-201-14 on 30/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class CollectorPickupHistoryController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pickupList: UITableView!
    
    
    struct PickupItem {
        let donation: Donation
        let ngoCase: NgoCases
        var donorName: String? = nil
    }

    var allPickups: [PickupItem] = []
    var filteredPickups: [PickupItem] = []
    var searchText: String = ""
    var selectedFilter: String? = nil
    let refreshControl = UIRefreshControl()


    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pickup History"
        searchBar.delegate = self
        setupFilterMenu()
        setupTableView()
        fetchDonations()
        
        refreshControl.addTarget(self, action: #selector(refreshPickupsData(_:)), for: .valueChanged)
        pickupList.refreshControl = refreshControl
        refreshControl.tintColor = UIColor.mainBrand500
        // Do any additional setup after loading the view.
    }


    
    private func setupTableView() {
        pickupList.dataSource = self
        pickupList.delegate = self
    }
    
    func setupFilterMenu() {
        let expiresAction = UIAction(
            title: "Expires Soon",
            image: UIImage(systemName: "exclamationmark.triangle"),
            identifier: nil,
            discoverabilityTitle: nil,
            attributes: [],
            state: .off) {[weak self] _ in
                guard let self = self else { return }
                self.selectedFilter = "Expires Soon"
                self.applyFilters()
        }

        let notExpiresAction = UIAction(
            title: "Have Time",
            image: UIImage(systemName: "clock"),
            attributes: [], state: .off) {[weak self] _ in
                guard let self = self else { return }
                self.selectedFilter = "Have Time"
                self.applyFilters()
        }

        let pendingAction = UIAction(
            title: "Pending",
            image: UIImage(systemName: "clock"),
            attributes: [],
            state: .off) {[weak self] _ in
                guard let self = self else { return }
                self.selectedFilter = "pending"
                self.applyFilters()
        }
        
        let acceptedAction = UIAction(
            title: "Accepted",
            image: UIImage(systemName: "checkmark.circle"),
            state: .off
        ) {[weak self] _ in
            guard let self = self else { return }
            self.selectedFilter = "accepted"
            self.applyFilters()
        }

        let collectedAction = UIAction(
            title: "Collected",
            image: UIImage(systemName: "tray.and.arrow.down"),
            state: .off
        ) {[weak self] _ in
            guard let self = self else { return }
            self.selectedFilter = "collected"
            self.applyFilters()
        }

        let expiresMenu = UIMenu(
            title: "Expiration",
            image: UIImage(systemName: "calendar"),
            options: [.displayInline],
            children: [expiresAction, notExpiresAction]
        )
        
        let statusMenu = UIMenu(
            title: "Status",
            image: UIImage(systemName: "person.crop.circle"),
            options: [.displayInline],
            children: [pendingAction, acceptedAction, collectedAction]
        )
        
        let clearAction = UIAction(
            title: "Clear Filters",
            image: UIImage(systemName: "xmark.circle"),
            attributes: [.destructive]
        ) { [weak self] _ in
            guard let self = self else { return }
            self.selectedFilter = nil
            self.searchText = ""
            self.searchBar.text = ""
            self.applyFilters()
        }
        

        let mainMenu = UIMenu(
            title: "Filter by",
            identifier: nil,
            options: [.singleSelection],                      // radio style selection
            children: [expiresMenu, statusMenu, clearAction]
        )

        // Assign to button
        filterButton.menu = mainMenu
    }
    
    private func fetchDonations() {
        let db = Firestore.firestore()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("ngoCases").whereField("ngoID", isEqualTo: uid).getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No Cases found")
                return
            }
            
            var casesById: [String: NgoCases] = [:]

            for document in documents {
                let data = document.data()
                print("Document data:", data) 
                if let ngoCase = NgoCases(id: document.documentID, dictionary: data) {
                    casesById[ngoCase.id] = ngoCase
                }else {
                    print("Failed to parse case:", data)
                }
            }
            
            self.fetchDonationsForCases(casesById)

        }
    }
    
    private func fetchDonationsForCases(_ casesById: [String: NgoCases]) {
        let db = Firestore.firestore()
        let group = DispatchGroup()
        
        db.collection("donations").getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No donations found")
                return
            }
            
            var items: [PickupItem] = []
            
            for document in documents {
                print("ID:", document.documentID, "Data:", document.data())
                let data = document.data()
                if let donation = Donation(id: document.documentID, dictionary: data), let ngoCase = casesById[donation.caseId] {
                    var item = PickupItem(donation: donation, ngoCase: ngoCase)
                    group.enter()
                    self.fetchUserName(userId: donation.donorId) { name in
                        item.donorName = name
                        items.append(item) 
                        group.leave()
                    }
                } else {
                    print("Failed to parse donation:", data)
                }
            }
            
            group.notify(queue: .main) {
                self.allPickups = items
                self.filteredPickups = items
                self.pickupList.reloadData()
            }
            
            DispatchQueue.main.async {
                self.updateEmptyState()
                self.pickupList.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }

    
    func fetchUserName(userId: String, completion: @escaping (String) -> Void) {
        let db = Firestore.firestore()

        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let name = data["name"] as? String {
                completion(name)
            } else {
                completion("Unknown User")
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        applyFilters()
    }
    
    private func applyFilters() {
        filteredPickups = allPickups.filter { donation in
            var matchesSearch = true
            var matchesFilter = true
            
            if !searchText.isEmpty {
                matchesSearch = donation.donation.foodName.lowercased().contains(searchText.lowercased()) || donation.donation.description.lowercased().contains(searchText.lowercased()) || donation.ngoCase.title.lowercased().contains(searchText.lowercased()) || donation.ngoCase.description.lowercased().contains(searchText.lowercased())
            }

            if let selectedFilter = selectedFilter {
                switch selectedFilter {
                case "Expires Soon":
                    let calendar = Calendar.current
                    if let daysUntilExpiration = calendar.dateComponents([.day], from: Date(), to: donation.donation.expiryDate).day {
                        matchesFilter = daysUntilExpiration <= 2
                    } else {
                        matchesFilter = false
                    }
                case "Have Time":
                    let calendar = Calendar.current
                    if let daysUntilExpiration = calendar.dateComponents([.day], from: Date(), to: donation.donation.expiryDate).day {
                        matchesFilter = daysUntilExpiration > 2
                    } else {
                        matchesFilter = false
                    }
                case "pending", "accepted", "collected":
                    matchesFilter = donation.donation.status.lowercased() == selectedFilter.lowercased()
                default:
                    matchesFilter = true
                }
            }
            
            return matchesSearch && matchesFilter
        }
        updateEmptyState()
        pickupList.reloadData()
    }

    private func updateEmptyState() {
        if filteredPickups.isEmpty {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: pickupList.bounds.size.width, height: pickupList.bounds.size.height))
            if !searchText.isEmpty && selectedFilter != nil {
                noDataLabel.text = "No results for \"\(searchText)\" and \(selectedFilter!)"
            } else if !searchText.isEmpty {
                noDataLabel.text = "No results found for \"\(searchText)\""
            } else if let filter = selectedFilter {
                noDataLabel.text = "No results found for \"\(filter)\""
            } else {
                noDataLabel.text = "No Pickups found."
            }
            noDataLabel.textColor = .gray
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 0
            noDataLabel.font = .systemFont(ofSize: 16, weight: .medium)
            
            pickupList.backgroundView = noDataLabel
        } else {
            pickupList.backgroundView = nil
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPickups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let donationsData = filteredPickups[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: "PickupCell", for: indexPath)as! CollectorPickupHistoryTableViewCell
        
        cell.pickupContainer.layer.cornerRadius = 12
        cell.pickupContainer.layer.borderWidth = 0.5
        cell.pickupContainer.layer.borderColor = UIColor.lightGray.cgColor
        cell.pickupContainer.layer.masksToBounds = true
        cell.foodImage.contentMode = .scaleAspectFill
        cell.foodImage.clipsToBounds = true
        cell.ngoCaseContainer.layer.cornerRadius = 12
        cell.ngoCaseImage.layer.cornerRadius = 5
        cell.ngoCaseImage.contentMode = .scaleAspectFill
        cell.ngoCaseImage.clipsToBounds = true
        
        cell.foodImage.loadImage(from: donationsData.donation.imageURL)
        cell.FoodName.text = donationsData.donation.foodName
        cell.foodBody.text = donationsData.donation.description
        cell.userName.text = donationsData.donorName
        cell.ngoCaseTitle.text = donationsData.ngoCase.title
    
        cell.ngoCaseImage.loadImage(from: donationsData.ngoCase.imageUrl)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_BH")
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        if let startDate = donationsData.ngoCase.startDate, let endDate = donationsData.ngoCase.endDate{
            let startDateString = dateFormatter.string(from: startDate)
            let endDateString = dateFormatter.string(from: endDate)
            cell.ngoCaseDate.text = "From \(startDateString)"
            cell.ngoCaseDateEnd.text = "To \(endDateString)"
        }

        
        let calendar = Calendar.current
        if let daysUntilExpiration = calendar.dateComponents([.day], from: Date(), to: donationsData.donation.expiryDate).day {
            cell.expiresSoonTag.isHidden = daysUntilExpiration > 2
        } else {
            cell.expiresSoonTag.isHidden = true
        }
        return cell
    }
    
    @objc private func refreshPickupsData(_ sender: Any) {
        fetchDonations()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedDonation = filteredPickups[indexPath.row]
        performSegue(withIdentifier: "ShowPickupDetails", sender: selectedDonation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 1. Check the segue identifier to ensure it's the correct transition
        if segue.identifier == "ShowPickupDetails" {
            // 2. Check the destination view controller type
            if let destinationVC = segue.destination as? CollectorPickupHistoryDetailsController {
                // 3. Check if the sender is the expected data type (the donation ID)
                if let selectedDonation = sender as? PickupItem { // Use the correct type for your ID (e.g., String, UUID, Int)
                    // 4. Pass the data to a property in the destination view controller
                    destinationVC.donationID = selectedDonation.donation.id
                    destinationVC.ngoID = selectedDonation.ngoCase.ngoId
                    segue.destination.navigationItem.title = "Pickup Details"
                }
            }
        }
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
