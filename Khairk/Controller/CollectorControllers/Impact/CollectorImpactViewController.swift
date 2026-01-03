//
//  CollectorImpactViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 27/12/2025.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

class CollectorImpactViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var mealsDeliveredTitleLabel: UILabel!
    @IBOutlet weak var monthlyProgressBar: UIProgressView!
    @IBOutlet weak var progressPercentageLabel: UILabel!
    
    @IBOutlet weak var donationsCollectedCountLabel: UILabel!
    @IBOutlet weak var familiesSupportedCountLabel: UILabel!
    @IBOutlet weak var activeCasesCountLabel: UILabel!
    @IBOutlet weak var peopleReachedCountLabel: UILabel!
    
    @IBOutlet weak var areaChartContainer: UIView!
    // MARK: - Properties
    let monthlyGoal: Int = 600
    private let db = Firestore.firestore()
    private var donationsListener: ListenerRegistration?
    private var casesListener: ListenerRegistration?
    
    var weeklyPickupData: [CGFloat] = [0, 0, 0, 0, 0, 0, 0]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCollectorImpactData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupAreaChart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        donationsListener?.remove()
        casesListener?.remove()
    }
}

// MARK: - Firebase Logic
extension CollectorImpactViewController {
    
    private func fetchCollectorImpactData() {
        guard let currentNgoID = Auth.auth().currentUser?.uid else { return }
        
        // 1. Fetch Active Cases from 'ngoCases'
        casesListener = db.collection("ngoCases")
            .whereField("ngoID", isEqualTo: currentNgoID)
            .addSnapshotListener { [weak self] snapshot, _ in
                let casesCount = snapshot?.documents.count ?? 0
                DispatchQueue.main.async {
                    self?.activeCasesCountLabel.text = "\(casesCount)"
                }
            }
        
        // 2. Fetch Donations and Calculate Stats
        donationsListener = db.collection("donations")
            .whereField("ngoID", isEqualTo: currentNgoID)
            .whereField("status", in: ["accepted", "collected", "completed"])
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                let donations = documents.compactMap { Donation(doc: $0) }
                
                let totalMeals = donations.reduce(0) { $0 + $1.quantity }
                let donationsCount = donations.count
                
                self.updateWeeklyChartData(from: donations)
                
                DispatchQueue.main.async {
                    // Pass calculations: 1 donation = 1 family / 1 person reached
                    self.updateUI(meals: totalMeals, donations: donationsCount, families: donationsCount, people: donationsCount)
                }
            }
    }
    
    private func updateUI(meals: Int, donations: Int, families: Int, people: Int) {
        // Display ONLY the number in the header
        self.mealsDeliveredTitleLabel.text = "\(meals)"
        
        self.donationsCollectedCountLabel.text = "\(donations)"
        self.familiesSupportedCountLabel.text = "\(families)"
        self.peopleReachedCountLabel.text = "\(people)"
        
        // Capping progress at 100%
        let rawProgress = Float(meals) / Float(monthlyGoal)
        let finalProgress = min(rawProgress, 1.0)
        
        self.monthlyProgressBar.setProgress(finalProgress, animated: true)
        self.progressPercentageLabel.text = "\(Int(finalProgress * 100))%"
        
        self.setupAreaChart()
    }
    
    private func updateWeeklyChartData(from donations: [Donation]) {
        let calendar = Calendar.current
        var weeklyCounts: [CGFloat] = [0, 0, 0, 0, 0, 0, 0]
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let dailyCount = donations.filter { calendar.isDate($0.createdAt, inSameDayAs: date) }.count
                weeklyCounts[6 - i] = CGFloat(dailyCount)
            }
        }
        self.weeklyPickupData = weeklyCounts
    }
}

// MARK: - Area Chart Drawing
extension CollectorImpactViewController {
    
    private func setupAreaChart() {
        areaChartContainer.layer.sublayers?.forEach { if $0 is CAShapeLayer || $0 is CAGradientLayer { $0.removeFromSuperlayer() } }
        
        guard weeklyPickupData.count > 0 else { return }
        
        let path = UIBezierPath()
        let width = areaChartContainer.bounds.width
        let height = areaChartContainer.bounds.height
        let maxVal = (weeklyPickupData.max() ?? 10) == 0 ? 10 : weeklyPickupData.max()!
        
        let columnXPoint = { (column: Int) -> CGFloat in
            let spacing = width / CGFloat(self.weeklyPickupData.count - 1)
            return CGFloat(column) * spacing
        }
        let columnYPoint = { (value: CGFloat) -> CGFloat in
            return height - (value / maxVal * height)
        }

        path.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(weeklyPickupData[0])))
        for i in 1..<weeklyPickupData.count {
            path.addLine(to: CGPoint(x: columnXPoint(i), y: columnYPoint(weeklyPickupData[i])))
        }

        // Gradient Background
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

        // Main Line
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = UIColor.systemGreen.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 3
        areaChartContainer.layer.addSublayer(lineLayer)

        // Data Points (Dots)
        for i in 0..<weeklyPickupData.count {
            let point = CGPoint(x: columnXPoint(i), y: columnYPoint(weeklyPickupData[i]))
            let dotPath = UIBezierPath(arcCenter: point, radius: 4, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            let dotLayer = CAShapeLayer()
            dotLayer.path = dotPath.cgPath
            dotLayer.fillColor = UIColor.black.cgColor
            areaChartContainer.layer.addSublayer(dotLayer)
        }
    }
}
