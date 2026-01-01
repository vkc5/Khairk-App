//
//  AdminUserManagementController.swift
//  Khairk
//
//  Created by BP-36-213-17 on 01/01/2026.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AdminUserManagementController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var donorsList: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var allDonors: [User] = []
    var filteredDonors: [User] = []
    var searchText: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Donors Manager"
        searchBar.delegate = self
        setupTableView()
        fetchDonors()
        // Do any additional setup after loading the view.
    }
    
    
    private func setupTableView() {
        donorsList.dataSource = self
        donorsList.delegate = self
    }
    
    
    private func fetchDonors() {
        let db = Firestore.firestore()
        
        db.collection("users").whereField("role", isEqualTo: "donor").getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No donations found")
                return
            }
            
            var fetchedDonors: [User] = []
            
            for document in documents {
                print("ID:", document.documentID, "Data:", document.data())
                let data = document.data()
                if let donation = User(id: document.documentID, dictionary: data) {
                    fetchedDonors.append(donation)
                }else {
                    print("Failed to parse donation:", data)
                }
            }
            print("Fetched donation count:", fetchedDonors.count)
            self.allDonors = fetchedDonors
            self.filteredDonors = fetchedDonors
            
            // Reload table view on main thread
            DispatchQueue.main.async {
                self.donorsList.reloadData()
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        applyFilters()
    }
    

    
    private func applyFilters() {
        filteredDonors = allDonors.filter { donor in
            var matchesSearch = true
            
            if !searchText.isEmpty {
                matchesSearch = donor.name.lowercased().contains(searchText.lowercased())
            }
            
            return matchesSearch
        }
        
        donorsList.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDonors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let donorsData = filteredDonors[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DonorCell", for: indexPath) as? AdminUserManagementTableViewCell else {
            return UITableViewCell()
        }
        
        cell.donorContainer.layer.cornerRadius = 12
        cell.donorContainer.layer.borderWidth = 0.5
        cell.donorContainer.layer.borderColor = UIColor.lightGray.cgColor
        cell.donorimage.layer.cornerRadius = cell.donorimage.frame.width / 2
        cell.donorimage.layer.borderWidth = 0.5
        cell.donorimage.layer.borderColor = UIColor.lightGray.cgColor
        cell.donorimage.layer.masksToBounds = true
        cell.donorimage.contentMode = .scaleAspectFill
        
        cell.name.text = donorsData.name
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_BH")
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        cell.joinDate.text = "Joind on \(dateFormatter.string(from: donorsData.createdAt))"
        if let url = donorsData.profileImageUrl, !url.isEmpty {
            cell.donorimage.loadImage(from: url)
        } else {
            cell.donorimage.image = UIImage(systemName: "person.circle.fill")
            cell.donorimage.tintColor = .mainBrand500
        }
    
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedDonor = filteredDonors[indexPath.row]
        performSegue(withIdentifier: "ShowDonorDetails", sender: selectedDonor.id)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDonorDetails" {
            if let userVC = segue.destination as? AdminUserManagementDetailsController {
                if let donorID = sender as? String {
                    userVC.donorID = donorID
                    if let sheet = userVC.sheetPresentationController {
                        sheet.detents = [.medium()]
                        sheet.prefersGrabberVisible = true
                        sheet.preferredCornerRadius = 24
                    }
                    
                    userVC.navigationItem.title = "Donor Details"
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
