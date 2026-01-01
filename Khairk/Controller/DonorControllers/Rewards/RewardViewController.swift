//
//  RewardViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 29/12/2025.
//
import UIKit

class RewardViewController: UIViewController {

    @IBOutlet weak var youWinLabel: UILabel!
    @IBOutlet weak var rewardTitleLabel: UILabel!
    @IBOutlet weak var rewardDescLabel: UILabel!
    @IBOutlet weak var couponCodeLabel: UILabel!
    @IBOutlet weak var copyCodeButton: UIButton!
    @IBOutlet weak var goHomeButton: UIButton!
    
    var winnerItem: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        displayRewardInfo()
    }
    
    func setupUI() {
        copyCodeButton.layer.cornerRadius = 25
        goHomeButton.layer.cornerRadius = 25
        self.navigationController?.isNavigationBarHidden = true
    }

    func generateRandomSuffix() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<5).map{ _ in letters.randomElement()! })
    }

    func displayRewardInfo() {
        guard let item = winnerItem else { return }
        var title = ""; var desc = ""; var prefix = ""
        
        switch item {
        case "iPhone": title = "IPHONE"; desc = "Special 20% OFF Discount"; prefix = "IPH-"
        case "Apple Watch": title = "WATCH"; desc = "Congratulations! It's FREE"; prefix = "WCH-"
        case "Iced Coffee": title = "COFFEE"; desc = "Enjoy Your Free Drink"; prefix = "COF-"
        case "iPad": title = "IPAD"; desc = "Special 10% OFF Discount"; prefix = "PAD-"
        case "Car": title = "CAR"; desc = "You Won A Brand New Car!"; prefix = "CAR-"
        case "Flight Ticket": title = "FLIGHT"; desc = "10% OFF Your Next Trip"; prefix = "FLY-"
        default: title = "GIFT"; desc = "A Special Gift For You"; prefix = "GFT-"
        }
        
        rewardTitleLabel.text = title
        rewardDescLabel.text = desc
        couponCodeLabel.text = "Code: \(prefix)\(generateRandomSuffix())"
    }

    @IBAction func copyCodeTapped(_ sender: UIButton) {
        let codeOnly = couponCodeLabel.text?.replacingOccurrences(of: "Code: ", with: "")
        UIPasteboard.general.string = codeOnly
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        var config = sender.configuration
        config?.title = "Copied"
        sender.configuration = config
        sender.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            sender.isUserInteractionEnabled = true
            var reset = sender.configuration
            reset?.title = "Copy Code"
            sender.configuration = reset
        }
    }

    // زر العودة: يرسل أمر التحديث ويعود للرئيسية
    @IBAction func goHomeTapped(_ sender: UIButton) {
        print("Go Home Tapped!")

        // 1. تفعيل علامة زيادة المستوى في الشاشة الرئيسية
        gameViewController.shouldLevelUp = true
        
        // 2. إرسال الإشعار (للاحتياط)
        NotificationCenter.default.post(name: NSNotification.Name("UserLeveledUp"), object: nil)
        
        // 3. العودة
        if let navController = self.navigationController {
            navController.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
