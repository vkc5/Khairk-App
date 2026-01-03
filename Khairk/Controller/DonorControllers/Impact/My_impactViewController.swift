//
//  My_impactViewControllerViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 17/12/2025.
//
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class My_impactViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var monthlySharedTitleLabel: UILabel!
    @IBOutlet weak var monthlyProgressBar: UIProgressView!
    @IBOutlet weak var progressPercentageLabel: UILabel!
    
    @IBOutlet weak var mealsCountLabel: UILabel!
    @IBOutlet weak var familiesCountLabel: UILabel!
    @IBOutlet weak var foodSavedCountLabel: UILabel!
    @IBOutlet weak var peopleReachedCountLabel: UILabel!
    
    @IBOutlet weak var areaChartContainer: UIView! // Ensure you replaced StackView with UIView in Storyboard
    
    // MARK: - Properties
    let monthlyGoal: Int = 50
    private let db = Firestore.firestore()
    private var donationsListener: ListenerRegistration?
    
    var weeklyActivityData: [CGFloat] = [0, 0, 0, 0, 0, 0, 0]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDonorImpactData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAreaChart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        donationsListener?.remove()
    }
}

// MARK: - Firebase Logic
extension My_impactViewController {
    
    private func fetchDonorImpactData() {
        // 1. Get current Donor UID
        guard let currentDonorID = Auth.auth().currentUser?.uid else { return }
        
        // 2. Listen to donations made by this specific donor
        donationsListener = db.collection("donations")
            .whereField("donorID", isEqualTo: currentDonorID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                // Assuming Donation struct handles document mapping
                let donations = documents.compactMap { Donation(doc: $0) }
                
                // --- Calculations Logic ---
                let totalDonationsCount = donations.count
                let totalMeals = donations.reduce(0) { $0 + $1.quantity }
                
                // 1 Donation = 1 Family / 1 Person / 1 KG saved
                let familiesHelped = totalDonationsCount
                let peopleReached = totalDonationsCount
                let foodSavedKG = Double(totalDonationsCount) * 1.0
                
                self.updateWeeklyActivity(from: donations)
                
                DispatchQueue.main.async {
                    self.updateUI(meals: totalMeals, families: familiesHelped, kg: foodSavedKG, people: peopleReached, sharedCount: totalDonationsCount)
                }
            }
    }
    
    private func updateUI(meals: Int, families: Int, kg: Double, people: Int, sharedCount: Int) {
        // Display only numbers in the labels
        self.monthlySharedTitleLabel.text = "\(sharedCount)"
        self.mealsCountLabel.text = "\(meals)"
        self.familiesCountLabel.text = "\(families)"
        self.foodSavedCountLabel.text = String(format: "%.1f", kg)
        self.peopleReachedCountLabel.text = "\(people)"
        
        // Progress Logic (Max 100%)
        let rawProgress = Float(sharedCount) / Float(monthlyGoal)
        let finalProgress = min(rawProgress, 1.0)
        
        self.monthlyProgressBar.setProgress(finalProgress, animated: true)
        self.progressPercentageLabel.text = "\(Int(finalProgress * 100))%"
        
        self.setupAreaChart()
    }
    
    private func updateWeeklyActivity(from donations: [Donation]) {
        let calendar = Calendar.current
        var dailyCounts: [CGFloat] = [0, 0, 0, 0, 0, 0, 0]
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let count = donations.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }.count
                dailyCounts[6 - i] = CGFloat(count)
            }
        }
        self.weeklyActivityData = dailyCounts
    }
}

// MARK: - Chart Logic (Area Chart with Dots)
extension My_impactViewController {
    
    private func setupAreaChart() {
        areaChartContainer.layer.sublayers?.forEach { if $0 is CAShapeLayer || $0 is CAGradientLayer { $0.removeFromSuperlayer() } }
        
        guard weeklyActivityData.count > 0 else { return }
        
        let path = UIBezierPath()
        let width = areaChartContainer.bounds.width
        let height = areaChartContainer.bounds.height
        let maxVal = (weeklyActivityData.max() ?? 10) == 0 ? 10 : weeklyActivityData.max()!
        
        let columnXPoint = { (column: Int) -> CGFloat in
            let spacing = width / CGFloat(self.weeklyActivityData.count - 1)
            return CGFloat(column) * spacing
        }
        let columnYPoint = { (value: CGFloat) -> CGFloat in
            return height - (value / maxVal * height)
        }

        path.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(weeklyActivityData[0])))
        for i in 1..<weeklyActivityData.count {
            path.addLine(to: CGPoint(x: columnXPoint(i), y: columnYPoint(weeklyActivityData[i])))
        }

        // 1. Gradient Fill
        let fillPath = UIBezierPath(cgPath: path.cgPath)
        fillPath.addLine(to: CGPoint(x: width, y: height))
        fillPath.addLine(to: CGPoint(x: 0, y: height))
        fillPath.close()

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = areaChartContainer.bounds
        gradientLayer.colors = [UIColor.systemGreen.withAlphaComponent(0.4).cgColor, UIColor.clear.cgColor]
        let maskLayer = CAShapeLayer()
        maskLayer.path = fillPath.cgPath
        gradientLayer.mask = maskLayer
        areaChartContainer.layer.addSublayer(gradientLayer)

        // 2. Stroke Line
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = UIColor.systemGreen.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 3
        areaChartContainer.layer.addSublayer(lineLayer)

        // 3. Black Dots
        for i in 0..<weeklyActivityData.count {
            let point = CGPoint(x: columnXPoint(i), y: columnYPoint(weeklyActivityData[i]))
            let dotPath = UIBezierPath(arcCenter: point, radius: 4, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            let dotLayer = CAShapeLayer()
            dotLayer.path = dotPath.cgPath
            dotLayer.fillColor = UIColor.black.cgColor
            areaChartContainer.layer.addSublayer(dotLayer)
        }
    }
}
