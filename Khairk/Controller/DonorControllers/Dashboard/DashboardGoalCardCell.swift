import UIKit

class DashboardGoalCardCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var goalImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!          // “Donate 100 meals”
    @IBOutlet weak var startLabel: UILabel!          // “Start: 12 Nov 2025”
    @IBOutlet weak var targetLabel: UILabel!         // “Target: 100 meals”
    @IBOutlet weak var raisedLabel: UILabel!         // “Raised 70”
    @IBOutlet weak var daysLeftLabel: UILabel!       // “Days left 30”
    @IBOutlet weak var progressView: UIProgressView!

    @IBOutlet weak var deleteButton: UIButton!       // exists but hidden

    override func awakeFromNib() {
        super.awakeFromNib()

        // card style
        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray5.cgColor
        cardView.clipsToBounds = true

        goalImageView.layer.cornerRadius = 8
        goalImageView.clipsToBounds = true

        deleteButton.isHidden = true     // ✅ dashboard = no delete
        deleteButton.isUserInteractionEnabled = false
    }


    private func loadImage(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.goalImageView.image = img }
        }.resume()
    }
    
    func configure(with goal: Goal, showDelete: Bool) {
        deleteButton.isHidden = !showDelete
        deleteButton.isUserInteractionEnabled = showDelete

        titleLabel.text = "Donate \(goal.targetAmount) meals"

        let df = DateFormatter()
        df.dateStyle = .medium
        startLabel.text = "Start: \(df.string(from: goal.startDate))"

        targetLabel.text = "Target: \(goal.targetAmount) meals"
        raisedLabel.text = "0"

        let daysLeft = max(0, Calendar.current.dateComponents([.day], from: Date(), to: goal.endDate).day ?? 0)
        daysLeftLabel.text = "\(daysLeft)"

        progressView.progress = 0

        if let url = goal.imageUrl, !url.isEmpty {
            loadImage(url)
        } else {
            goalImageView.image = UIImage(systemName: "photo")
        }
    }



}
