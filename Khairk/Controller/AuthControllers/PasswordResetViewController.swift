//
//  PasswordResetViewController.swift
//  Khairk
//
//  Created by vkc5 on 25/11/2025.
//

import UIKit

class PasswordResetViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Password Reset"      // screen 1
        
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

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        let rawEmail = emailTextField.text ?? ""
        let email = rawEmail.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !email.isEmpty else {
            showAlert(title: "Missing Email", message: "Please enter your email address.")
            return
        }

        AuthService.shared.sendPasswordReset(to: email) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                     // after user taps OK, you can navigate to the "VerificationCode" UI
                    self?.goToVerificationInfo()
                    print("✅ Password reset requested for \(email)")

                case .failure(let error):
                    print("❌ Password reset error:", error.localizedDescription)
                    self?.showAlert(
                        title: "Error",
                        message: error.localizedDescription
                    )
                }
            }
        }
    }
    
    private func goToVerificationInfo() {
        let sb = UIStoryboard(name: "Auth", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "VerificationCodeVC")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
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
