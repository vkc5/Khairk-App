//
//  AdminNGOVerificationController.swift
//  Khairk
//
//  Created by BP-19-130-16 on 31/12/2025.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AdminNGOVerificationController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchWithScope: UISearchBar!
    @IBOutlet weak var ngoList: UITableView!
    var allNGOs: [User] = []
    var filteredNGOs: [User] = []
    var searchText: String = ""
    var selectedFilter: String = "All"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NGO Verification (Manager)"
        searchWithScope.delegate = self
        setupTableView()
        fetchNGOs()
        // Do any additional setup after loading the view.
    }
    
    private func setupTableView() {
        ngoList.dataSource = self
        ngoList.delegate = self
    }
    
    
    private func fetchNGOs() {
        let db = Firestore.firestore()
        
        db.collection("users").whereField("role", isEqualTo: "collector").getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No donations found")
                return
            }
            
            var fetchedDonations: [User] = []
            
            for document in documents {
                print("ID:", document.documentID, "Data:", document.data())
                let data = document.data()
                if let donation = User(id: document.documentID, dictionary: data) {
                    fetchedDonations.append(donation)
                }else {
                    print("Failed to parse donation:", data)
                }
            }
            print("Fetched donation count:", fetchedDonations.count)
            self.allNGOs = fetchedDonations
            self.filteredNGOs = fetchedDonations
            
            // Reload table view on main thread
            DispatchQueue.main.async {
                self.ngoList.reloadData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        applyFilters()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.selectedFilter = searchWithScope.scopeButtonTitles?[selectedScope] ?? "All"
        applyFilters()
    }
    
    private func applyFilters() {
        filteredNGOs = allNGOs.filter { ngo in
            var matchesSearch = true
            var matchesFilter = true
            
            if !searchText.isEmpty {
                matchesSearch = ngo.name.lowercased().contains(searchText.lowercased())
            }

            switch selectedFilter {
            case "Pending":
                matchesFilter = ngo.applicationStatus?.lowercased() == "pending"
            case "Complete":
                matchesFilter = ngo.applicationStatus?.lowercased() == "approved" || ngo.applicationStatus?.lowercased() == "rejected"
            default:
                matchesFilter = true
            }
            
            return matchesSearch && matchesFilter
        }
        
        ngoList.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNGOs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ngosData = filteredNGOs[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NGOCell", for: indexPath) as? AdminNGOVerificationTableViewCell else {
            return UITableViewCell()
        }
        
        cell.ngoContainer.layer.cornerRadius = 12
        cell.ngoContainer.layer.borderWidth = 0.5
        cell.ngoContainer.layer.borderColor = UIColor.lightGray.cgColor
        cell.ngoImage.layer.cornerRadius = 10
        cell.ngoImage.layer.borderWidth = 0.5
        cell.ngoArea.layer.borderColor = UIColor.lightGray.cgColor
        cell.ngoImage.layer.masksToBounds = true
        cell.ngoImage.contentMode = .scaleAspectFill
        
        if let url = ngosData.logoUrl, !url.isEmpty {
            cell.ngoImage.loadImage(from: url)
        }
        cell.ngoName.text = ngosData.name
        if let status = ngosData.applicationStatus {
            switch ngosData.applicationStatus?.lowercased() {
            case "pending":
                cell.ngoStatusIcon.image = UIImage(systemName: "hourglass")
                cell.ngoStatus.text = "Pending"
                cell.ngoStatus.textColor = .gray
                cell.ngoStatusIcon.tintColor = .gray
            case "approved":
                cell.ngoStatusIcon.image = UIImage(systemName: "checkmark.circle.fill")
                cell.ngoStatus.text = "Approved"
                cell.ngoStatus.textColor = UIColor.mainBrand500
                cell.ngoStatusIcon.tintColor = UIColor.mainBrand500
            case "rejected":
                cell.ngoStatusIcon.image = UIImage(systemName: "xmark.circle.fill")
                cell.ngoStatus.text = "Rejected"
                cell.ngoStatus.textColor = .red
                cell.ngoStatusIcon.tintColor = .red
            default:
                cell.ngoStatusIcon.image = UIImage(systemName: "questionmark.circle")
                cell.ngoStatus.text = status.capitalized
                cell.ngoStatus.textColor = .black
                cell.ngoStatusIcon.tintColor = .black
            }
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_BH")
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        cell.ngoJoinDate.text = "Joind on \(dateFormatter.string(from: ngosData.createdAt))"
        cell.ngoArea.text = ngosData.serviceArea
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedNGO = filteredNGOs[indexPath.row]
        performSegue(withIdentifier: "ShowNGODetails", sender: selectedNGO.id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 1. Check the segue identifier to ensure it's the correct transition
        if segue.identifier == "ShowNGODetails" {
            // 2. Check the destination view controller type
            if let userVC = segue.destination as? AdminNGOVerificationDetailsController {
                // 3. Check if the sender is the expected data type (the donation ID)
                if let ngoID = sender as? String { // Use the correct type for your ID (e.g., String, UUID, Int)
                    // 4. Pass the data to a property in the destination view controller
                    userVC.ngoID = ngoID
                    segue.destination.navigationItem.title = "NGO Details"
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
