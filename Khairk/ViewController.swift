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
                // bounce to full size
                self.logoImageView.transform = .identity
                self.logoImageView.alpha = 1.0
            },
            completion: nil
        )
    }


}

