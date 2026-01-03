//
//  CollectorProfileRootViewController.swift
//  Khairk
//
//  Created by vkc5 on 01/01/2026.
//

import UIKit

class CollectorProfileRootViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openRealProfile()
    }

    private func openRealProfile() {
        let sb = UIStoryboard(name: "CollectorProfile", bundle: nil)
        let profileVC = sb.instantiateViewController(withIdentifier: "CollectorProfileVC")

        // replace the placeholder root with the real profile screen
        navigationController?.setViewControllers([profileVC], animated: false)
    }

}
