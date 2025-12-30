//
//  SelectRoleViewController.swift
//  Khairk
//
//  Created by vkc5 on 25/11/2025.
//

import UIKit

class SelectRoleViewController: UIViewController {

    @IBOutlet weak var donorCardView: UIView!
    @IBOutlet weak var collectorCardView: UIView!
    @IBOutlet weak var continueButton: UIButton!
    
    enum UserRole {
        case donor
        case collector
    }

    private var selectedRole: UserRole? = nil

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        navigationItem.title = "Select Role"      // screen
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    func setupUI() {
        // card appearance
        [donorCardView, collectorCardView].forEach { card in
            card?.layer.cornerRadius = 16
            card?.layer.borderWidth = 1
            card?.layer.borderColor = UIColor.systemGray4.cgColor
            card?.backgroundColor = .white
            card?.clipsToBounds = true
        }

        // continue button initially disabled
        continueButton.isEnabled = false
        continueButton.alpha = 0.5
    }

    func setupGestures() {
        donorCardView.isUserInteractionEnabled = true
        collectorCardView.isUserInteractionEnabled = true

        let donorTap = UITapGestureRecognizer(target: self, action: #selector(donorTapped))
        let collectorTap = UITapGestureRecognizer(target: self, action: #selector(collectorTapped))

        donorCardView.addGestureRecognizer(donorTap)
        collectorCardView.addGestureRecognizer(collectorTap)
    }

    @objc func donorTapped() {
        selectedRole = .donor
        updateSelectionUI()
    }

    @objc func collectorTapped() {
        selectedRole = .collector
        updateSelectionUI()
    }
    
    func updateSelectionUI() {
        let green = UIColor(red: 7/255, green: 119/255, blue: 52/255, alpha: 1) // your app green

        switch selectedRole {
        case .donor:
            donorCardView.layer.borderColor = green.cgColor
            donorCardView.backgroundColor = green.withAlphaComponent(0.08)

            collectorCardView.layer.borderColor = UIColor.systemGray4.cgColor
            collectorCardView.backgroundColor = .white

        case .collector:
            collectorCardView.layer.borderColor = green.cgColor
            collectorCardView.backgroundColor = green.withAlphaComponent(0.08)

            donorCardView.layer.borderColor = UIColor.systemGray4.cgColor
            donorCardView.backgroundColor = .white

        case .none:
            break
        }

        // enable Continue when a role is selected
        continueButton.isEnabled = (selectedRole != nil)
        continueButton.alpha = continueButton.isEnabled ? 1.0 : 0.5
    }

    @IBAction func continueTapped(_ sender: UIButton) {
        guard let role = selectedRole else {
            // optional: show alert
            let alert = UIAlertController(title: "Select a role",
                                          message: "Please choose Donor or Collector to continue.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let storyboard = UIStoryboard(name: "Auth", bundle: nil)

        switch role {
        case .donor:
            let sb = UIStoryboard(name: "Auth", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "DonorSignUpVC")
            navigationController?.pushViewController(vc, animated: true)
        case .collector:
            let sb = UIStoryboard(name: "Auth", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "CollectorSignUpVC")
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func signInTapped(_ sender: UITapGestureRecognizer) {
        navigationController?.popToRootViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
