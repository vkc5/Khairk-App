//
//  InfoViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 29/12/2025.
//
import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var okButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // جعل الزر مستديراً ليتناسب مع تصميمك الجميل
        okButton.layer.cornerRadius = 20
    }
    
    // الأكشن المسؤول عن إغلاق الشاشة (البوب أب)
    @IBAction func okButtonTapped(_ sender: UIButton) {
        // هذا السطر يقوم بإغلاق الشاشة الحالية والعودة للخلف
        self.dismiss(animated: true, completion: nil)
    }
}
