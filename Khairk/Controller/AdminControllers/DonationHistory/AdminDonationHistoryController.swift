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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All Donations"
        searchBar.delegate = self
        setupFilterMenu()
        setupTableView()
        // Do any additional setup after loading the view.
    }
    
    private func setupTableView() {
        donationsList.dataSource = self
        donationsList.delegate = self
        donationsList.rowHeight = UITableView.automaticDimension
        donationsList.estimatedRowHeight = 100
    }
    
    func setupFilterMenu() {
        let expiresAction = UIAction(
            title: "Expires Soon",
            image: UIImage(systemName: "exclamationmark.triangle"),
            identifier: nil,
            discoverabilityTitle: nil,
            attributes: [],
            state: .off) { _ in
            print("Food selected")
        }

        let notExpiresAction = UIAction(
            title: "Have Time",
            image: UIImage(systemName: "clock"),
            attributes: [], state: .off) {_ in
            print("Education selected")
        }

        let pendingAction = UIAction(
            title: "Pending",
            image: UIImage(systemName: "clock"),
            attributes: [],
            state: .off) { _ in
            print("Health selected")
        }
        
        let acceptedAction = UIAction(
            title: "Accepted",
            image: UIImage(systemName: "checkmark.circle"),
            state: .off
        ) { _ in
            print("Accepted selected")
        }

        let collectedAction = UIAction(
            title: "Collected",
            image: UIImage(systemName: "tray.and.arrow.down"),
            state: .off
        ) { _ in
            print("Collected selected")
        }

        let expiresMenu = UIMenu(
            title: "Expiration",
            image: UIImage(systemName: "calendar"),
            options: [.displayInline],
            children: [expiresAction, notExpiresAction]
        )
        
        let statusMenu = UIMenu(
            title: "Status",
            image: UIImage(systemName: "person.crop.circle"), // optional icon
            options: [.displayInline],
            children: [pendingAction, acceptedAction, collectedAction]
        )
        
        let clearAction = UIAction(
            title: "Clear Filters",
            image: UIImage(systemName: "xmark.circle"),
            attributes: [.destructive]
        ) { [weak self] _ in
            
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDonations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notificationData = filteredDonations[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: "DonationCell", for: indexPath)as! AdminNotificationTableViewCell
        
        cell.notificationContainer.layer.cornerRadius = 12
        cell.notificationContainer.layer.borderWidth = 1
        

        return cell
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
