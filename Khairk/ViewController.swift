//
//  ViewController.swift
//  Khairk
//
//  Created by vkc5 on 22/11/2025.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Firebase current user:", Auth.auth().currentUser as Any)
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateLogoBounce()
    }

    func animateLogoBounce() {
        // start smaller & invisible
        logoImageView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        logoImageView.alpha = 0.0

        UIView.animate(
            withDuration: 0.9,
            delay: 0.1,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut,
            animations: {
                self.logoImageView.transform = .identity
                self.logoImageView.alpha = 1.0
            },
            completion: { _ in
                // Small extra delay if you want (optional)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.goToLogin()
                }
            }
        )

    }
    
    func goToLogin() {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")

        // Smooth fade animation
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {

            UIView.transition(
                with: window,
                duration: 0.4,
                options: .transitionCrossDissolve,
                animations: {
                    window.rootViewController = UINavigationController(rootViewController: loginVC)
                },
                completion: nil
            )
        } else {
            // Fallback
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true)
        }
    }


}

