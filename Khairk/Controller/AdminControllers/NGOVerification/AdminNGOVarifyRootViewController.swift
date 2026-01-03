//
//  AdminNGOVarifyRootViewController.swift
//  Khairk
//
//  Created by vkc5 on 01/01/2026.
//

import UIKit

class AdminNGOVarifyRootViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openRealProfile()
    }

    private func openRealProfile() {
        let sb = UIStoryboard(name: "AdminNGOVerification", bundle: nil)
        let profileVC = sb.instantiateViewController(withIdentifier: "AdminNGOVerificationVC")

        // replace the placeholder root with the real profile screen
        navigationController?.setViewControllers([profileVC], animated: false)
    }

}
