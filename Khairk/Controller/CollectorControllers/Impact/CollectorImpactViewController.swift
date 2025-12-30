//
//  CollectorImpactViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 27/12/2025.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

class CollectorImpactViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mealsDeliveredTitleLabel: UILabel! // العنوان الرئيسي (مثلاً: 480 Meals Delivered)
    @IBOutlet weak var monthlyProgressBar: UIProgressView!
    @IBOutlet weak var progressPercentageLabel: UILabel!
    
    @IBOutlet weak var donationsCollectedCountLabel: UILabel! // المربع 1: Donations Collected
    @IBOutlet weak var familiesSupportedCountLabel: UILabel!  // المربع 2: Families Supported
    @IBOutlet weak var activeCasesCountLabel: UILabel!        // المربع 3: Active Cases
    @IBOutlet weak var peopleReachedCountLabel: UILabel!      // المربع 4: People Reached
    
    @IBOutlet weak var chartStackView: UIStackView! // الجارت الخاص بـ Pickups
    
    // MARK: - Properties
    let monthlyGoal: Int = 600 // الهدف الشهري للتوصيل بناءً على التصميم (70% من 600 تقريباً 420-480)
    private let db = Firestore.firestore()
    
    // بيانات الرسم البياني لعمليات الاستلام (Pickups)
    var weeklyPickupData: [CGFloat] = [10, 25, 23, 15, 30, 18, 22]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // عرض البيانات الوهمية حالياً للتأكد من الشكل
        showCollectorMockData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // رسم الجارت بناءً على البيانات
        setupWeeklyPickupsChart()
    }
}

// MARK: - UI & Mock Data Logic
extension CollectorImpactViewController {
    
    private func showCollectorMockData() {
        let mockData: [String: Any] = [
            "mealsDelivered": 480,
            "donationsCollected": 64,
            "familiesSupported": 38,
            "activeCases": 6,
            "peopleReached": 28,
            "weeklyPickups": [10, 25, 23, 15, 30, 18, 22]
        ]
        updateCollectorUI(with: mockData)
    }

    private func updateCollectorUI(with data: [String: Any]) {
        let delivered = data["mealsDelivered"] as? Int ?? 0
        
        // تحديث النصوص حسب التصميم الجديد
        self.mealsDeliveredTitleLabel.text = "\(delivered)"
        self.donationsCollectedCountLabel.text = "\(data["donationsCollected"] as? Int ?? 0)"
        self.familiesSupportedCountLabel.text = "\(data["familiesSupported"] as? Int ?? 0)"
        self.activeCasesCountLabel.text = "\(data["activeCases"] as? Int ?? 0)"
        self.peopleReachedCountLabel.text = "\(data["peopleReached"] as? Int ?? 0)"
        
        // تحديث شريط التقدم والنسبة المئوية
        let progress = Float(delivered) / Float(monthlyGoal)
        self.monthlyProgressBar.setProgress(progress, animated: true)
        self.progressPercentageLabel.text = "\(Int(progress * 100))%"
        
        // تلوين الشريط بالأخضر إذا اكتمل الهدف
        if progress >= 1.0 {
            self.monthlyProgressBar.progressTintColor = .systemGreen
        }
    }
}

// MARK: - Chart Logic (Pickups Activity)
extension CollectorImpactViewController {
    
    private func setupWeeklyPickupsChart() {
        // تنظيف الجارت قبل الرسم
        chartStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        chartStackView.axis = .horizontal
        chartStackView.distribution = .fillEqually
        chartStackView.alignment = .bottom
        chartStackView.spacing = 8
        
        // تحديد المقياس الأعلى للرسم
        guard let maxPickups = weeklyPickupData.max(), maxPickups > 0 else { return }
        
        for value in weeklyPickupData {
            let bar = UIView()
            bar.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.7)
            bar.layer.cornerRadius = 4
            
            chartStackView.addArrangedSubview(bar)
            bar.translatesAutoresizingMaskIntoConstraints = false
            
            // حساب الارتفاع النسبي
            let heightMultiplier = value / maxPickups
            bar.heightAnchor.constraint(equalTo: chartStackView.heightAnchor, multiplier: heightMultiplier).isActive = true
            
            // انيميشن الظهور
            bar.alpha = 0
            UIView.animate(withDuration: 0.6) {
                bar.alpha = 1
            }
        }
    }
}
