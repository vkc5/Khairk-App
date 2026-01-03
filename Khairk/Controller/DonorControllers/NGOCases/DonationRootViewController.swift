//
//  DonationRootViewController.swift
//  Khairk
//
//  Created by vkc5 on 01/01/2026.
//

import UIKit

class DonationRootViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openRealProfile()
    }

    private func openRealProfile() {
        let sb = UIStoryboard(name: "DonorNGOCases", bundle: nil)
        let profileVC = sb.instantiateViewController(withIdentifier: "FoodDonationViewController")

        // replace the placeholder root with the real profile screen
        navigationController?.setViewControllers([profileVC], animated: false)
    }

}
