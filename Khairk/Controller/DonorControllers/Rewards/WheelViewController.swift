//
//  WheelViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 29/12/2025.
//
import UIKit

class WheelViewController: UIViewController {

    @IBOutlet weak var wheelView: UIImageView!
    @IBOutlet weak var spinButton: UIButton!
    
    // مصفوفة الجوائز مرتبة حسب أماكنها في الصورة (بدءاً من الأعلى لليمين)
    let rewards = ["iPhone", "Apple Watch", "Iced Coffee", "iPad", "Car", "Flight Ticket"]
    var isSpinning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wheelView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        spinButton.layer.cornerRadius = spinButton.frame.height / 2
        spinButton.clipsToBounds = true
    }

    @IBAction func spinButtonTapped(_ sender: UIButton) {
        guard !isSpinning else { return }
        isSpinning = true
        sender.isEnabled = false
        
        // --- منطق الاحتمالات الجديد ---
        let winningIndex = calculateWinningIndex()
        let winningReward = rewards[winningIndex]
        // ------------------------------
        
        // حساب الزاوية بناءً على المؤشر الفائز
        let anglePerSection = (CGFloat.pi * 2) / 6
        let rotationAngle = (CGFloat.pi * 2 * 5) + (CGFloat(winningIndex) * anglePerSection)
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = rotationAngle
        animation.duration = 4.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.performSegue(withIdentifier: "showReward", sender: winningReward)
                self.isSpinning = false
                self.spinButton.isEnabled = true
            }
        }
        wheelView.layer.add(animation, forKey: "spin")
        CATransaction.commit()
    }

    // دالة حساب الجائزة بناءً على النسبة
    func calculateWinningIndex() -> Int {
        // نحدد "وزن" كل جائزة (مجموع الأوزان هنا 100 لسهولة الحساب)
        // الترتيب: iPhone, Apple Watch, Iced Coffee, iPad, Car, Flight Ticket
        let weights = [2, 8, 60, 10, 5, 15]
        // شرح الأوزان: الكوفي 60%، التذكرة 15%، الأيفون 2% فقط!
        
        let totalWeight = weights.reduce(0, +)
        let randomNumber = Int.random(in: 0..<totalWeight)
        
        var currentSum = 0
        for (index, weight) in weights.enumerated() {
            currentSum += weight
            if randomNumber < currentSum {
                return index
            }
        }
        return 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showReward", let dest = segue.destination as? RewardViewController {
            dest.winnerItem = sender as? String
        }
    }
}
