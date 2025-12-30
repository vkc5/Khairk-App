//
//  DonorVerificationCodeViewController.swift
//  Khairk
//
//  Created by vkc5 on 05/12/2025.
//

import UIKit

class AdminVerificationCodeViewController: UIViewController, UITextFieldDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Verification Code"      // screen 1

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        goToLogin()
    }
    func goToLogin() {
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
