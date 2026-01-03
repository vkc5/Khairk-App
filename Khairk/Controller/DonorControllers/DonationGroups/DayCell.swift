//
//  DayCell.swift
//  Khairk
//
//  Created by FM on 16/12/2025.
//

import UIKit

final class DayCell: UICollectionViewCell {

    enum Shape {
        case circle
        case rounded(CGFloat)
    }

    var shape: Shape = .circle {
        didSet { setNeedsLayout() }
    }

    private let bubbleView = UIView()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.backgroundColor = .clear
        bubbleView.layer.borderWidth = 1
        bubbleView.layer.borderColor = UIColor.systemGray4.cgColor
        bubbleView.clipsToBounds = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 6),
            titleLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -6),
            titleLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 6),
            titleLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -6)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        switch shape {
        case .circle:
            bubbleView.layer.cornerRadius = min(bubbleView.bounds.width, bubbleView.bounds.height) / 2
        case .rounded(let r):
            bubbleView.layer.cornerRadius = r
        }
    }

    //highlight should NEVER change the style (prevents "hover" look)
    override var isHighlighted: Bool {
        didSet { /* do nothing */ }
    }

    func configure(text: String, selected: Bool) {
        titleLabel.text = text

        bubbleView.layer.borderWidth = selected ? 2 : 1
        bubbleView.layer.borderColor = selected ? UIColor.systemGreen.cgColor : UIColor.systemGray4.cgColor
        bubbleView.backgroundColor = selected ? UIColor.systemGreen.withAlphaComponent(0.10) : .clear
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        bubbleView.layer.borderWidth = 1
        bubbleView.layer.borderColor = UIColor.systemGray4.cgColor
        bubbleView.backgroundColor = .clear
    }
}

