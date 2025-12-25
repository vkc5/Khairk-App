//
//  AdminDonationHistoryController.swift
//  Khairk
//
//  Created by BP-19-130-16 on 25/12/2025.
//

import UIKit

class AdminDonationHistoryController: UIViewController {

    @IBOutlet weak var filterButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All Donations"
        setupFilterMenu()
        // Do any additional setup after loading the view.
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
            attributes: [],
            state: .off
        ) { [weak self] _ in
            self?.clearFilters()
        }


        let mainMenu = UIMenu(
            title: "Filter by",
            identifier: nil,
            options: [.singleSelection],                      // radio style selection
            children: [expiresMenu, statusMenu]
        )

        // Assign to button
        filterButton.menu = mainMenu
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
