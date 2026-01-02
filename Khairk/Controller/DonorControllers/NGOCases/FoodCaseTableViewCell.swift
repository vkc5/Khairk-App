//
//  FoodCaseTableViewCell.swift
//  Khairk
//
//  Created by Yousif Qassim on 01/01/2026.
//

import UIKit

class FoodCaseTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var caseImageView: UIImageView!
    @IBOutlet weak var caseNameLabel: UILabel!
    @IBOutlet weak var ngoNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var daysLeftLabel: UILabel!   // Displays number (e.g., 22)
    @IBOutlet weak var percentageLabel: UILabel! // Displays percentage (e.g., 85%)
    @IBOutlet weak var statsLabel: UILabel!      // Displays status (e.g., Expiring soon)

    // MARK: - Closures
    // These allow the ViewController to handle button actions dynamically
    var onViewDetailsTapped: (() -> Void)?
    var onDonationFormTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Card style formatting for a modern look
        cardView.layer.cornerRadius = 15
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        
        // Image appearance settings
        caseImageView.layer.cornerRadius = 12
        caseImageView.clipsToBounds = true
        
        // --- Safe Progress Bar configuration ---
        progressBar.layer.cornerRadius = 6
        progressBar.clipsToBounds = true
        
        // Verify sublayers exist before modifying corners to prevent IndexOutOfBounds crash
        if let layers = progressBar.layer.sublayers, layers.count > 1 {
            layers[1].cornerRadius = 6
        }
        
        // Allow the description to wrap correctly
        descriptionLabel.numberOfLines = 0
    }

    // Standard iOS method to ensure layers update their shapes when the layout changes
    override func layoutSubviews() {
        super.layoutSubviews()
        // Re-apply corner radius to internal progress layer
        if let layers = progressBar.layer.sublayers, layers.count > 1 {
            layers[1].cornerRadius = progressBar.layer.cornerRadius
        }
    }

    // MARK: - Actions
    @IBAction func viewDetailsClicked(_ sender: Any) {
        onViewDetailsTapped?()
    }
    
    @IBAction func donationFormClicked(_ sender: Any) {
        onDonationFormTapped?()
    }
    
    // Critical for smooth scrolling: Resets the cell before it is reused for new data
    override func prepareForReuse() {
        super.prepareForReuse()
        caseImageView.image = nil
        progressBar.progress = 0
        percentageLabel.text = "0%"
        daysLeftLabel.text = "0"
        statsLabel.text = ""
        // Reset colors to default to prevent "Expiring soon" red leaking into a "New" blue label
        statsLabel.textColor = .label
    }
}
