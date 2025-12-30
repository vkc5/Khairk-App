//
//  AddGroupStep2ViewController 2.swift
//  Khairk
//
//  Created by FM on 16/12/2025.
//


import UIKit

final class AddGroupStep2ViewController: UIViewController {

    var draft = DonationGroupDraft()

    override func viewDidLoad() {
        super.viewDidLoad()
        // For debugging:
        print("Step2 draft name:", draft.groupName)
    }
}
