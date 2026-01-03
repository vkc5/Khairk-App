//
//  DonationCardCell.swift
//  Khairk
//
//  Created by FM on 18/12/2025.
//

import UIKit

final class DonationCardCell: UITableViewCell {

    
    var onViewDetailsTapped: (() -> Void)?

      @IBAction private func viewDetailsTapped(_ sender: UIButton) {
          onViewDetailsTapped?()
      }
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var donationImageView: UIImageView!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var contactButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!

    private var didSetupConstraints = false
    private var currentImageURL: String?

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        setupCardUI()
        setupButtonsUI()
        setupProgressUI()
        setupImageUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // shadowPath
        cardView.layer.shadowPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 16).cgPath
    }

    private func setupCardUI() {
        
        
        // Make the cell background transparent so the card looks like a floating card.
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        // Card styling (rounded corners + border + subtle shadow).
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.systemGray5.cgColor
        cardView.backgroundColor = .systemBackground

        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.layer.masksToBounds = false
    }

    private func setupButtonsUI() {
        styleFilledButton(contactButton, title: "Contact NGO")
        styleFilledButton(detailsButton, title: "View Details")
    }

    private func styleFilledButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.setTitleColor(.white, for: .normal)

        button.backgroundColor = UIColor.mainBrand500
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
    }

    private func setupProgressUI() {
        progressView.trackTintColor = .systemGray5
        progressView.progressTintColor = UIColor.mainBrand500

        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
    }

    private func setupImageUI() {
        donationImageView.clipsToBounds = true
        donationImageView.layer.cornerRadius = 12
        donationImageView.contentMode = .scaleAspectFill
    }

    func configure(foodName: String,
                   quantity: Int,
                   statusText: String,
                   progress: Float,
                   imageURL: String?) {

        foodNameLabel.text = foodName
        detailsLabel.text = "Quantity: \(quantity) • Status: \(statusText)"
        progressView.progress = progress

        loadImage(from: imageURL)
    }

    private func loadImage(from urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            donationImageView.image = UIImage(systemName: "photo")
            currentImageURL = nil
            return
        }

        currentImageURL = urlString
        donationImageView.image = UIImage(systemName: "photo")

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            guard let data = data, let img = UIImage(data: data) else { return }
            guard self.currentImageURL == urlString else { return }

            DispatchQueue.main.async {
                self.donationImageView.image = img
            }
        }.resume()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        currentImageURL = nil
        donationImageView.image = UIImage(systemName: "photo")
    }

    
    override func updateConstraints() {
        super.updateConstraints()
        guard !didSetupConstraints else { return }
        didSetupConstraints = true

        cardView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
