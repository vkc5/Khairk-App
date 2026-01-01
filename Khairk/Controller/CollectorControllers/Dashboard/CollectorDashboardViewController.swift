//
//  CollectorDashboardViewController.swift
//  Khairk
//
//  Created by Ghaida Buhmaid on 15/12/2025.

 

import UIKit

class CollectorDashboardViewController: UIViewController {

    // MARK: - Outlets

    // Top boxes (Mycase, Acceptdonation, Mypickup, Stats)
    @IBOutlet weak var Mycase: UIView!
    @IBOutlet weak var Acceptdonation: UIView!
    @IBOutlet weak var Mypickup: UIView!
    @IBOutlet weak var statsView: UIView!
    @IBOutlet weak var ProfileView: UIView!

    // Spotlight cards (two)
    @IBOutlet weak var spotlightView1: UIView!
    @IBOutlet weak var spotlightView2: UIView!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // TOP BOXES
        styleTopBox(Mycase)
        styleTopBox(Acceptdonation)
        styleTopBox(Mypickup)
        styleTopBox(statsView)
        styleTopBox(ProfileView)

        styleSpotlight(spotlightView1)
        styleSpotlight(spotlightView2)
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // gradient must be re-applied after the view gets its final size
        styleSpotlight(spotlightView1)
        styleSpotlight(spotlightView2)
    }


    // MARK: - Style Functions

    // Top small boxes
    func styleTopBox(_ view: UIView) {
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.clipsToBounds = true
    }

    // Goal cards (bigger radius)
    func styleGoalCard(_ view: UIView) {
        // Rounded card
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.masksToBounds = true

        // INNER PADDING (this fixes the issue you want)
        view.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        view.preservesSuperviewLayoutMargins = false
    }


    // Spotlight gradient style
    func styleSpotlight(_ view: UIView) {

        // Remove old gradient layers to avoid stacking
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradient = CAGradientLayer()
        gradient.frame = view.bounds

        // Green gradient left → right
        gradient.colors = [
            UIColor(red: 0/255, green: 140/255, blue: 80/255, alpha: 1).cgColor,
            UIColor(red: 0/255, green: 180/255, blue: 100/255, alpha: 1).cgColor
        ]

        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        gradient.cornerRadius = 16

        // Insert gradient at background
        view.layer.insertSublayer(gradient, at: 0)

        view.layer.cornerRadius = 16
        view.clipsToBounds = true
    }
    
    @IBAction func Add1(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "NGOCasesManagement", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "MyCasesVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func Add2(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "NGOCasesManagement", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "MyCasesVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func ProfileTapped(_ sender: UIButton) {        
        let storyboard = UIStoryboard(name: "CollectorProfile", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "CollectorProfileVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)

    }
    
    @IBAction func ImpactTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "CollectorImpact", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "My_impactViewController")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func ImpactTapped2(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CollectorImpact", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "My_impactViewController")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func AddCaseTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "NGOCasesManagement", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "MyCasesVC")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @IBAction func MyPickup(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "CollectorPickupHistory", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "CollectorPickupHistoryController")

        mapVC.hidesBottomBarWhenPushed = true   // 🔴 hides tab bar

        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    
    
    
}
