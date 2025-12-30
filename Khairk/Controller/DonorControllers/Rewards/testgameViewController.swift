//
//  testgameViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 28/12/2025.
//

import UIKit

class testgameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func startButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToGame", sender: nil)
    }
    
}
