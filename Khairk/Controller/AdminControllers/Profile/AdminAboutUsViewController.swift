//
//  AboutUsViewController.swift
//  Khairk
//
//  Created by vkc5 on 04/12/2025.
//

import UIKit

class AdminAboutUsViewController: UIViewController {
    
    @IBOutlet var teamCardViews: [UIView]!   // connect ALL of them here

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for view in teamCardViews {
                applyCardStyle(to: view)
            }
        // Do any additional setup after loading the view.
    }
    func applyCardStyle(to view: UIView) {
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = false   // IMPORTANT for shadow

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.15
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 6
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
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
