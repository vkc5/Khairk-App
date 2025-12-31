//
//  VerificationCodeViewController.swift
//  Khairk
//
//  Created by vkc5 on 25/11/2025.
//

import UIKit

class VerificationCodeViewController: UIViewController, UITextFieldDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Verification Code"      // screen 1

        let backImage = UIImage(systemName: "chevron.left")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: backImage,
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    @objc func backTapped() {
        navigationController?.popViewController(animated: true)
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
