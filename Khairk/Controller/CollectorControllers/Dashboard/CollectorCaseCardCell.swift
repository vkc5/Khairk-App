import UIKit

class CollectorCaseCardCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var caseImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var raisedLabel: UILabel!
    @IBOutlet weak var daysLeftLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.black.cgColor
        cardView.clipsToBounds = true

        caseImageView.layer.cornerRadius = 10
        caseImageView.clipsToBounds = true
    }

    func configure(with c: NgoCase) {
        titleLabel.text = c.title

        let df = DateFormatter()
        df.dateStyle = .medium
        startLabel.text = "Start: \(df.string(from: c.startDate))"

        // target text (your design: "Target: 100 meals")
        targetLabel.text = "Target: \(c.goal) \(c.foodType)"

        // collected == raised
        raisedLabel.text = "\(c.collected)"

        let daysLeft = max(0, Calendar.current.dateComponents([.day], from: Date(), to: c.endDate).day ?? 0)
        daysLeftLabel.text = "\(daysLeft)"

        let progress = c.goal > 0 ? Float(c.collected) / Float(c.goal) : 0
        progressView.progress = min(max(progress, 0), 1)

        if let url = c.imageURL, !url.isEmpty {
            loadImage(url)
        } else {
            caseImageView.image = UIImage(systemName: "photo")
        }
    }

    private func loadImage(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.caseImageView.image = img }
        }.resume()
    }
}
