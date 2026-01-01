//
//  CollectorPickupRootViewController.swift
//  Khairk
//
//  Created by vkc5 on 01/01/2026.
//

import UIKit

class CollectorPickupRootViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openRealProfile()
    }

    private func openRealProfile() {
        let sb = UIStoryboard(name: "PickupManagement", bundle: nil)
        let profileVC = sb.instantiateViewController(withIdentifier: "NGOActivePickupsVC")

        // replace the placeholder root with the real profile screen
        navigationController?.setViewControllers([profileVC], animated: false)
    }

}
