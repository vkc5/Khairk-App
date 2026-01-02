//
//  FoodCaseViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 20/12/2025.
//

import UIKit

class FoodCaseViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var caseImageView: UIImageView?
    @IBOutlet weak var caseNameLabel: UILabel?
    @IBOutlet weak var ngoNameLabel: UILabel?
    @IBOutlet weak var caseDetailsInfoLabel: UILabel?
    @IBOutlet weak var progressBar: UIProgressView?
    @IBOutlet weak var percentageLabel: UILabel?
    @IBOutlet weak var statsLabel: UILabel!    // Displays Status (e.g., Expiring soon)
    @IBOutlet weak var daysLeftLabel: UILabel! // Displays the number of remaining days
    @IBOutlet weak var donateNowButton: UIButton?

    var selectedCase: FoodDonationViewController.NgoCase?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        displayData()
    }

    private func setupUI() {
        // Aesthetic UI configurations
        caseImageView?.layer.cornerRadius = 12
        caseImageView?.clipsToBounds = true
        
        donateNowButton?.layer.cornerRadius = 15
        
        // Ensure the description text can expand to multiple lines
        caseDetailsInfoLabel?.numberOfLines = 0
    }

    private func displayData() {
        // Verify data was received from the previous screen
        guard let item = selectedCase else {
            print("Warning: No case data received (selectedCase is nil)")
            return
        }

        // 1. Basic Text Content
        caseNameLabel?.text = item.title
        ngoNameLabel?.text = item.name
        caseDetailsInfoLabel?.text = item.description
        statsLabel?.text = item.statusText
        
        // 2. Update status label color based on the value
        updateStatusColor(status: item.statusText)

        // 3. Calculate and update Progress Bar and Percentage Label
        if item.goal > 0 {
            let ratio = Float(item.currentRaised / item.goal)
            progressBar?.progress = ratio
            percentageLabel?.text = "\(Int(ratio * 100))%"
        } else {
            progressBar?.progress = 0
            percentageLabel?.text = "0%"
        }

        // 4. Calculate remaining days dynamically
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: item.endDate)
        let days = components.day ?? 0
        daysLeftLabel?.text = "\(max(0, days))"

        // 5. Load image safely from URL
        if let urlString = item.imageURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self?.caseImageView?.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }

    private func updateStatusColor(status: String) {
        // Set label color based on status text
        switch status {
        case "Expired":
            statsLabel?.textColor = .systemRed
        case "Expiring soon":
            statsLabel?.textColor = .systemOrange
        case "New":
            statsLabel?.textColor = .systemBlue
        default:
            statsLabel?.textColor = .systemGreen
        }
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        // Safe navigation back whether using Navigation Controller or Modal Presentation
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
