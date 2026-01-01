//
//  AdminDonationHistoryController.swift
//  Khairk
//
//  Created by BP-19-130-16 on 25/12/2025.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AdminDonationHistoryController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var donationsList: UITableView!
    var allDonations: [Donation] = []
    var filteredDonations: [Donation] = []
    var searchText: String = ""
    var selectedFilter: String? = nil
    
    var loader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All Donations"
        searchBar.delegate = self
        setupFilterMenu()
        setupTableView()
        setupLoader()
        fetchDonations()
        // Do any additional setup after loading the view.
    }

    private func setupLoader() {
        view.addSubview(loader)
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    
    private func setupTableView() {
        donationsList.dataSource = self
        donationsList.delegate = self
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
            
            var fetchedDonations: [Donation] = []
            
            for document in documents {
                print("ID:", document.documentID, "Data:", document.data())
                let data = document.data()
                if let donation = Donation(id: document.documentID, dictionary: data) {
                    fetchedDonations.append(donation)
                }else {
                    print("Failed to parse donation:", data)
                }
            }
            print("Fetched donation count:", fetchedDonations.count)
            self.allDonations = fetchedDonations
            self.filteredDonations = fetchedDonations
            
            // Reload table view on main thread
            DispatchQueue.main.async {
                self.donationsList.reloadData()
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
        filteredDonations = allDonations.filter { donation in
            var matchesSearch = true
            var matchesFilter = true
            
            if !searchText.isEmpty {
                matchesSearch = donation.foodName.lowercased().contains(searchText.lowercased()) ||  donation.description.lowercased().contains(searchText.lowercased())
            }

            if let selectedFilter = selectedFilter {
                switch selectedFilter {
                case "Expires Soon":
                    let calendar = Calendar.current
                    if let daysUntilExpiration = calendar.dateComponents([.day], from: Date(), to: donation.expiryDate).day {
                        matchesFilter = daysUntilExpiration <= 2
                    } else {
                        matchesFilter = false
                    }
                case "Have Time":
                    let calendar = Calendar.current
                    if let daysUntilExpiration = calendar.dateComponents([.day], from: Date(), to: donation.expiryDate).day {
                        matchesFilter = daysUntilExpiration > 2
                    } else {
                        matchesFilter = false
                    }
                case "pending", "accepted", "collected":
                    matchesFilter = donation.status.lowercased() == selectedFilter.lowercased()
                default:
                    matchesFilter = true
                }
            }
            
            return matchesSearch && matchesFilter
        }
        
        donationsList.reloadData()
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDonations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let donationsData = filteredDonations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DonationCell", for: indexPath)as! AdminDonationHistoryTableViewCell
        
        cell.container.layer.cornerRadius = 12
        cell.container.layer.borderWidth = 0.5
        
        cell.foodName?.text = donationsData.foodName
        fetchUserName(userId: donationsData.donorId) { name in
            DispatchQueue.main.async {
                cell.userName.text = name
            }
        }
        cell.status?.text = donationsData.status
        cell.foodImage.loadImage(from: donationsData.imageURL)
        let calendar = Calendar.current
        if let daysUntilExpiration = calendar.dateComponents([.day], from: Date(), to: donationsData.expiryDate).day {
            cell.expiresSoonTag.isHidden = daysUntilExpiration > 2
        } else {
            cell.expiresSoonTag.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedDonation = filteredDonations[indexPath.row]
        performSegue(withIdentifier: "ShowDonationDetails", sender: selectedDonation.id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 1. Check the segue identifier to ensure it's the correct transition
        if segue.identifier == "ShowDonationDetails" {
            // 2. Check the destination view controller type
            if let destinationVC = segue.destination as? AdminDonationDetailsController {
                // 3. Check if the sender is the expected data type (the donation ID)
                if let donationID = sender as? String { // Use the correct type for your ID (e.g., String, UUID, Int)
                    // 4. Pass the data to a property in the destination view controller
                    destinationVC.donationID = donationID
                    segue.destination.navigationItem.title = "Donation Details"
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
