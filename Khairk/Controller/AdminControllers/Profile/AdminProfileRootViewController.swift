//
//  AdminProfileRootViewController.swift
//  Khairk
//
//  Created by vkc5 on 01/01/2026.
//

import UIKit

class AdminProfileRootViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openRealProfile()
    }

    private func openRealProfile() {
        let sb = UIStoryboard(name: "AdminProfile", bundle: nil)
        let profileVC = sb.instantiateViewController(withIdentifier: "AdminProfileVC")

        // replace the placeholder root with the real profile screen
        navigationController?.setViewControllers([profileVC], animated: false)
    }

}
