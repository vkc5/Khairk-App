//
//  GoalCardCellTableViewCell.swift
//  Khairk
//
//  Created by vkc5 on 19/12/2025.
//

import UIKit

class GoalCardCellTableViewCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var goalImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!          // "Donate 100 meals"
    @IBOutlet weak var startLabel: UILabel!          // "Start: 12 Nov 2025"

    @IBOutlet weak var targetValueLabel: UILabel!    // "100 meals" (green text)
    @IBOutlet weak var raisedNumberLabel: UILabel!   // number under Raised
    @IBOutlet weak var daysLeftNumberLabel: UILabel! // number under Days left

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var deleteGoalButton: UIButton!

    var onDeleteTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray5.cgColor
        cardView.clipsToBounds = true

        goalImageView.layer.cornerRadius = 10
        goalImageView.clipsToBounds = true
        goalImageView.contentMode = .scaleAspectFill

    }

    func configure(goal: Goal) {
            // Title like your design
            titleLabel.text = "Donate \(goal.targetAmount) meals"
            startLabel.text = "Start: \(formatDate(goal.startDate))"

            // Target bottom left
            targetValueLabel.text = "\(goal.targetAmount) meals"

            // You don't store raised yet -> 0 for now
            raisedNumberLabel.text = "\(goal.raised)"

            // Days left
            let daysLeft = max(0, daysBetween(Date(), goal.endDate))
            daysLeftNumberLabel.text = "\(daysLeft)"

            // Progress (0 now)
            progressView.progress = 0

            // Image (if exists)
            if let urlString = goal.imageUrl, let url = URL(string: urlString) {
                loadImage(url: url)
            } else {
                goalImageView.image = UIImage(named: "goal_placeholder") ?? UIImage(systemName: "photo")
            }
        }

        @IBAction func deleteTapped(_ sender: UIButton) {
            onDeleteTapped?()
        }

        private func formatDate(_ date: Date) -> String {
            let f = DateFormatter()
            f.dateFormat = "dd MMM yyyy"
            return f.string(from: date)
        }

        private func daysBetween(_ from: Date, _ to: Date) -> Int {
            let cal = Calendar.current
            let start = cal.startOfDay(for: from)
            let end = cal.startOfDay(for: to)
            return cal.dateComponents([.day], from: start, to: end).day ?? 0
        }

        private func loadImage(url: URL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async { self?.goalImageView.image = img }
            }.resume()
        }

}
