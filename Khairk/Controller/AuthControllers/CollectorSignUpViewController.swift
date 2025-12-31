//
//  CollectorSignUpViewController.swift
//  Khairk
//
//  Created by vkc5 on 25/11/2025.
//

import UIKit

class CollectorSignUpViewController: UIViewController {
    
    @IBOutlet weak var ngoNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueTapped(_ sender: UIButton) {
        
        let ngoName = (ngoNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = (phoneTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = (passwordTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !ngoName.isEmpty, !email.isEmpty, !phone.isEmpty, !password.isEmpty else {
            showAlert(title: "Missing Info", message: "Please fill all fields.")
            return
        }

        guard password.count >= 6 else {
            showAlert(title: "Weak Password", message: "Password must be at least 6 characters.")
            return
        }

        // Build the object that holds everything from this page
        let signupData = CollectorSignupData(
            ngoName: ngoName,
            email: email,
            phone: phone,
            password: password
        )

        goToCompleteDetails(with: signupData)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // show it again when we leave this screen
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func signInTapped(_ sender: UITapGestureRecognizer) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func goToCompleteDetails(with data: CollectorSignupData) {
        // Storyboard ID of the next VC must be set to "CompleteNGODetailsVC"
        guard let vc = storyboard?.instantiateViewController(
            withIdentifier: "CompleteNGODetailsVC"
        ) as? CompleteNGODetailsViewController else {
            return
        }

        vc.signupData = data    // pass it forward
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
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
