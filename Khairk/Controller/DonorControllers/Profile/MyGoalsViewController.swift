//
//  MyGoalsViewController.swift
//  Khairk
//
//  Created by vkc5 on 18/12/2025.
//

import UIKit

class MyGoalsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addGoalsTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "DonorProfile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "addGoalsVC")

        vc.modalPresentationStyle = .pageSheet

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                .custom { _ in 490 }   // 👈 height in points
            ]
            sheet.prefersGrabberVisible = true
        }

        present(vc, animated: true)
    }
    
    @IBAction func ViewGoalsTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "DonorProfile", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ViewGoalsVC")

        vc.modalPresentationStyle = .pageSheet

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                .custom { _ in 790 }   // 👈 height in points
            ]
            sheet.prefersGrabberVisible = true
        }

        present(vc, animated: true)
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
