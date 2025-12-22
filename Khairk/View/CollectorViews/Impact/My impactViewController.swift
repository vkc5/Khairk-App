//
//  My impactViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 14/12/2025.
//

import UIKit

class My_impactViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var topCardView: UIView!
    @IBOutlet weak var mealsDonatedCard: UIView!
    @IBOutlet weak var familiesHelpedCard: UIView!
    @IBOutlet weak var foodSavedCard: UIView!
    @IBOutlet weak var peopleReachedCard: UIView!
    
    private let progressBar = ProgressBar()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Impact"
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemGroupedBackground
        setupTopCard()
        setupGridCards()
    }
    
    private func setupTopCard() {
        topCardView.applyCardStyle()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon
        let icon = UIImageView(image: UIImage(named: "hand_icon")?.withRenderingMode(.alwaysTemplate))
        icon.tintColor = .systemGreen
        icon.contentMode = .scaleAspectFit
        icon.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "125 Meals Shared"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        
        // Subtitle and Percentage
        let subtitleStack = UIStackView()
        subtitleStack.axis = .horizontal
        subtitleStack.distribution = .fill
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Your Monthly Impact"
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let percentageLabel = UILabel()
        percentageLabel.text = "70%"
        percentageLabel.font = .systemFont(ofSize: 14, weight: .medium)
        percentageLabel.textColor = .systemGreen
        percentageLabel.textAlignment = .right
        percentageLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        subtitleStack.addArrangedSubview(subtitleLabel)
        subtitleStack.addArrangedSubview(percentageLabel)
        
        // Progress Bar
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.heightAnchor.constraint(equalToConstant: 8).isActive = true
        progressBar.setProgress(0.7, animated: false)
        
        // Add arranged subviews
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleStack)
        stackView.addArrangedSubview(progressBar)
        
        topCardView.addSubview(stackView)
        
        // Add constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topCardView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: topCardView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: topCardView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: topCardView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupGridCards() {
        // Meals Donated
        setupGridCard(
            container: mealsDonatedCard,
            iconName: "fork.knife",
            count: "36",
            unit: "Meals",
            subtitle: "Meals Donated"
        )
        
        // Families Helped
        setupGridCard(
            container: familiesHelpedCard,
            iconName: "person.2",
            count: "22",
            unit: "Families",
            subtitle: "Families Helped"
        )
        
        // Food Saved
        setupGridCard(
            container: foodSavedCard,
            iconName: "leaf",
            count: "42.0",
            unit: "kg",
            subtitle: "Food Saved"
        )
        
        // People Reached
        setupGridCard(
            container: peopleReachedCard,
            iconName: "person.2.wave.2",
            count: "28",
            unit: "People",
            subtitle: "People Reached"
        )
    }
    
    private func setupGridCard(container: UIView, iconName: String, count: String, unit: String, subtitle: String) {
        container.applyCardStyle()
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = .systemGreen
        iconView.contentMode = .scaleAspectFit
        iconView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        
        // Count and Unit Stack
        let countStack = UIStackView()
        countStack.axis = .horizontal
        countStack.spacing = 4
        countStack.alignment = .lastBaseline
        
        let countLabel = UILabel()
        countLabel.text = count
        countLabel.font = .systemFont(ofSize: 24, weight: .bold)
        countLabel.textColor = .darkText
        
        let unitLabel = UILabel()
        unitLabel.text = unit
        unitLabel.font = .systemFont(ofSize: 14, weight: .regular)
        unitLabel.textColor = .gray
        
        countStack.addArrangedSubview(countLabel)
        countStack.addArrangedSubview(unitLabel)
        
        // Subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .darkGray
        
        // Add arranged subviews
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(countStack)
        stackView.addArrangedSubview(subtitleLabel)
        
        container.addSubview(stackView)
        
        // Add constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - UIView Extension
extension UIView {
    func applyCardStyle() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 16
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.1
        self.layer.masksToBounds = false
    }
}

// MARK: - Progress Bar
private class ProgressBar: UIView {
    private let progressLayer = CALayer()
    private var progress: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = 4
        layer.masksToBounds = true
        backgroundColor = UIColor.systemGray5
        
        progressLayer.backgroundColor = UIColor.systemGreen.cgColor
        progressLayer.frame = CGRect(origin: .zero, size: CGSize(width: 0, height: bounds.height))
        layer.addSublayer(progressLayer)
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool = true) {
        let validatedProgress = min(max(progress, 0), 1)
        self.progress = validatedProgress
        
        let targetWidth = bounds.width * validatedProgress
        let animation = CABasicAnimation(keyPath: "bounds.size.width")
        animation.fromValue = progressLayer.bounds.width
        animation.toValue = targetWidth
        animation.duration = animated ? 0.3 : 0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        progressLayer.bounds.size.width = targetWidth
        progressLayer.add(animation, forKey: "progressAnimation")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressLayer.cornerRadius = layer.cornerRadius
        progressLayer.frame.origin = .zero
        progressLayer.frame.size.height = bounds.height
    }
}
