//
//  FoodCaseViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 20/12/2025.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseSharedSwift


class FoodCaseViewController: UIViewController {
    
    // Variable to receive data from the previous screen
    var selectedCase: DonationCase?
    
    // UI Outlets from Storyboard
    @IBOutlet weak var caseImageView: UIImageView!
    @IBOutlet weak var caseNameLabel: UILabel!       // Case Name
    @IBOutlet weak var ngoNameLabel: UILabel!     // NGO Name
    @IBOutlet weak var statementLabel: UILabel!   // Case Statement
    @IBOutlet weak var detailsInfoLabel: UILabel! // Case Details Info
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var percentageLabel: UILabel!  // Raised 10%
    @IBOutlet weak var daysLeftLabel: UILabel!    // Days left 22
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Ensure data is available
        guard let data = selectedCase else { return }
        
        // Populate UI elements with data
         caseNameLabel.text = data.title
         ngoNameLabel.text = data.ngoName
         statementLabel.text = data.description    // Or any specific field for the statement
         detailsInfoLabel.text = data.description
        
        // Calculate progress
                let progress = data.targetAmount > 0 ? Float(data.raisedAmount / data.targetAmount) : 0
                progressView.progress = progress
                percentageLabel.text = "Raised \(Int(progress * 100))%"
                daysLeftLabel.text = "Days left \(data.daysLeft)"
                
                // Download and set image
                if let url = URL(string: data.imageUrl) {
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        if let imageData = data {
                            DispatchQueue.main.async {
                                self.caseImageView.image = UIImage(data: imageData)
                            }
                        }
                    }.resume()
                }
            }
    
    @IBAction func donateNowPressed(_ sender: UIButton) {
        // Logic for navigating to the payment or donation page
            }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
        }
