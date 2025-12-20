//
//  NGOBottomSheetViewController.swift
//  Khairk
//
//  Created by vkc5 on 17/12/2025.
//

import UIKit
import CoreLocation

final class NGOBottomSheetViewController: UIViewController {

    var ngoName: String = ""
    var ngoCoordinate: CLLocationCoordinate2D!
    var onDirectionsTapped: (() -> Void)?

    private let nameLabel = UILabel()
    private let directionsButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        nameLabel.text = ngoName
        nameLabel.font = .boldSystemFont(ofSize: 22)

        directionsButton.setTitle("Get Directions", for: .normal)
        directionsButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        directionsButton.addTarget(self, action: #selector(directionsTapped), for: .touchUpInside)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        directionsButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nameLabel)
        view.addSubview(directionsButton)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            directionsButton.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            directionsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            directionsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            directionsButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func directionsTapped() {
        dismiss(animated: true)
        onDirectionsTapped?()
    }
}

