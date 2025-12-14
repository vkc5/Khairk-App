//
//  LoginViewController.swift
//  Khairk
//
//  Created by vkc5 on 24/11/2025.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBarAppearance()
        // Do any additional setup after loading the view.
    }

    func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white          // bar color
        appearance.shadowColor = .clear              // remove bottom line
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 24)
        ]

        UINavigationBar.appearance().tintColor = .black  // back arrow color
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        let rawEmail = emailTextField.text ?? ""
        let rawPassword = passwordTextField.text ?? ""

        print("RAW EMAIL: [\(rawEmail)]")

        let email = rawEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = rawPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        print("TRIMMED EMAIL: [\(email)]")

        guard !email.isEmpty, !password.isEmpty else {
            showAlert(title: "Missing Info", message: "Please enter email and password.")
            return
        }

        AuthService.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("✅ Logged in as \(user.email), role: \(user.role)")
                    self?.navigateToProfileAsRoot()
                    // NEXT STEP: navigate based on user.role
                case .failure(let error):
                    self?.showAlert(title: "Login Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UITapGestureRecognizer) {
        let sb = UIStoryboard(name: "Auth", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "PasswordResetVC")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func signUpTapped(_ sender: UITapGestureRecognizer) {
        let sb = UIStoryboard(name: "Auth", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SelectRoleVC")
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func navigateToProfileAsRoot() {
        let storyboard = UIStoryboard(name: "AdminProfile", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: "AdminProfileVC")

        let nav = UINavigationController(rootViewController: profileVC)
        nav.navigationBar.isHidden = false

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = scene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {

            UIView.transition(with: window,
                              duration: 0.35,
                              options: .transitionCrossDissolve,
                              animations: {
                window.rootViewController = nav
            })
        }
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
