//
//  My_impactViewControllerViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 17/12/2025.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
// import FirebaseAuth // فعل هذا السطر لاحقاً عند دمج تسجيل الدخول
import FirebaseSharedSwift

// MARK: - 1. Impact Data Model
// This model matches the structure required for the Community Impact Dashboard.
struct UserImpact: Codable {
    let monthlyGoal: Int
    let monthlyShared: Int
    let mealsDonated: Int
    let familiesHelped: Int
    let foodSavedKG: Double
    let peopleReached: Int
}

class My_impactViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var monthlySharedTitleLabel: UILabel!
    @IBOutlet weak var monthlyProgressBar: UIProgressView!
    @IBOutlet weak var progressPercentageLabel: UILabel!
    
    @IBOutlet weak var mealsCountLabel: UILabel!
    @IBOutlet weak var familiesCountLabel: UILabel!
    @IBOutlet weak var foodSavedCountLabel: UILabel!
    @IBOutlet weak var peopleReachedCountLabel: UILabel!
    
    @IBOutlet weak var chartStackView: UIStackView! // خاص بأعمدة الرسم
       
    
    
    // MARK: - Properties
        // الهدف باقٍ على 50 ليتناسب مع التصميم الحالي
        let communityGoal: Int = 50
        private let db = Firestore.firestore()
        
        // بيانات النشاط الأسبوعي الوهمية (عدد التبرعات في اليوم)
        var weeklyActivityData: [CGFloat] = [12, 25, 40, 15, 50, 30, 20]
        
        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // عرض البيانات الوهمية للمربعات
            showMockData()
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            // رسم الأعمدة بناءً على أرقام التبرعات
            setupWeeklyChart()
        }
    }

    // MARK: - Chart Logic (رسم التبرعات اليومية)
    extension My_impactViewController {
        
        private func setupWeeklyChart() {
            chartStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            chartStackView.axis = .horizontal
            chartStackView.distribution = .fillEqually
            chartStackView.alignment = .bottom
            chartStackView.spacing = 10
            
            // نحدد أعلى قيمة لتكون مقياس الرسم (الـ 100%)
            guard let maxDonations = weeklyActivityData.max(), maxDonations > 0 else { return }
            
            for donations in weeklyActivityData {
                let bar = UIView()
                bar.backgroundColor = .systemGreen
                bar.layer.cornerRadius = 4
                
                chartStackView.addArrangedSubview(bar)
                bar.translatesAutoresizingMaskIntoConstraints = false
                
                // نسبة الارتفاع تعتمد على أعلى يوم تبرع في الأسبوع
                let heightMultiplier = donations / maxDonations
                bar.heightAnchor.constraint(equalTo: chartStackView.heightAnchor, multiplier: heightMultiplier).isActive = true
                
                // تأثير ظهور تدريجي
                bar.alpha = 0
                UIView.animate(withDuration: 0.8) {
                    bar.alpha = 1
                }
            }
        }
    }

    // MARK: - UI Mock Data (البيانات الوهمية)
    extension My_impactViewController {
        
        private func showMockData() {
            let mockData: [String: Any] = [
                "monthlyShared": 35, // حالياً 35 من 50 (يعني النسبة ستكون 70%)
                "mealsDonated": 42,
                "familiesHelped": 18,
                "foodSavedKG": 25.5,
                "peopleReached": 50
            ]
            updateUI(with: mockData)
        }

        private func updateUI(with data: [String: Any]) {
            self.monthlySharedTitleLabel.text = "\(data["monthlyShared"] as? Int ?? 0)"
            self.mealsCountLabel.text = "\(data["mealsDonated"] as? Int ?? 0)"
            self.familiesCountLabel.text = "\(data["familiesHelped"] as? Int ?? 0)"
            self.foodSavedCountLabel.text = String(format: "%.1f", data["foodSavedKG"] as? Double ?? 0.0)
            self.peopleReachedCountLabel.text = "\(data["peopleReached"] as? Int ?? 0)"
            
            let shared = Float(data["monthlyShared"] as? Int ?? 0)
            let progress = shared / Float(communityGoal)
            self.monthlyProgressBar.setProgress(progress, animated: true)
            self.progressPercentageLabel.text = "\(Int(progress * 100))%"
            
            if progress >= 1.0 {
                self.monthlyProgressBar.progressTintColor = .systemGreen
            }
        }
    }

    // MARK: - Firebase Bridge (للربط لاحقاً)
    /*
    extension My_impactViewController {
        private func fetchUserDataFromFirestore() {
            // guard let userId = Auth.auth().currentUser?.uid else { return }
            // db.collection("users").document(userId).addSnapshotListener { snapshot, error in
            //    if let data = snapshot?.data() {
            //        self.updateUI(with: data)
            //    }
            // }
        }
    }
    */
