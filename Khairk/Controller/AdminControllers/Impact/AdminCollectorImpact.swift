//
//  AdminCollectorImpact.swift
//  Khairk
//
//  Created by Yousif Qassim on 27/12/2025.
//
import UIKit
import FirebaseFirestore

class AdminCollectorImpact: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var donutContainerView: UIView!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var donutStatusDescriptionLabel: UILabel!
    
    @IBOutlet weak var totalMealsProcessedLabel: UILabel!
    @IBOutlet weak var areaChartContainer: UIView!
    
    @IBOutlet weak var todayMealsLabel: UILabel!
    @IBOutlet weak var monthlyMealsLabel: UILabel!
    @IBOutlet weak var allTimeMealsLabel: UILabel!

    // MARK: - Properties
    private let db = Firestore.firestore()
    private var donationsListener: ListenerRegistration?
    
    // البيانات التي سيتم تحديثها ديناميكياً
    private var weeklyActivityData: [CGFloat] = [0, 0, 0, 0, 0, 0, 0]
    private var currentRate: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchImpactData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // إيقاف الاستماع للبيانات عند إغلاق الصفحة لمنع الـ Crash
        donationsListener?.remove()
    }

    // MARK: - Data Logic (Firebase)
    private func fetchImpactData() {
        donationsListener = db.collection("donations").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else { return }
            
            // 1. تحويل البيانات لـ Objects (يفترض وجود Donation Model)
            let allDonations = documents.compactMap { Donation(doc: $0) }
            let calendar = Calendar.current
            
            // --- حساب النسبة المئوية (Pickups Only) ---
            let pickupCompleted = allDonations.filter { $0.status == "collected" || $0.status == "completed" }.count
            let pickupPending = allDonations.filter { $0.status == "pending" }.count
            let totalPickups = pickupCompleted + pickupPending
            self.currentRate = totalPickups > 0 ? CGFloat(pickupCompleted) / CGFloat(totalPickups) : 0
            
            // --- وصف الدائرة (إجمالي العمليات الناجحة) ---
            let successTotal = allDonations.filter { $0.status == "collected" || $0.status == "completed" }.count
            
            // --- إجمالي الوجبات (بشتى أنواعها Pickups + Delivery) ---
            let totalMeals = allDonations.reduce(0) { $0 + $1.quantity }
            
            // --- الإحصائيات (شرط Status: accepted أو المكتملة) ---
            let acceptedDonations = allDonations.filter { $0.status == "accepted" || $0.status == "collected" || $0.status == "completed" }
            
            let todaySum = acceptedDonations.filter { calendar.isDateInToday($0.createdAt ?? Date()) }.reduce(0) { $0 + $1.quantity }
            let monthSum = acceptedDonations.filter { calendar.isDate($0.createdAt ?? Date(), equalTo: Date(), toGranularity: .month) }.reduce(0) { $0 + $1.quantity }
            let allTimeSum = acceptedDonations.reduce(0) { $0 + $1.quantity }

            // --- حساب بيانات المنحنى (آخر 7 أيام للوجبات المقبولة) ---
            var tempWeekly: [CGFloat] = [0, 0, 0, 0, 0, 0, 0]
            for i in 0..<7 {
                let date = calendar.date(byAdding: .day, value: -i, to: Date())!
                let daySum = acceptedDonations.filter { calendar.isDate($0.createdAt ?? Date(), inSameDayAs: date) }.reduce(0) { $0 + $1.quantity }
                tempWeekly[6-i] = CGFloat(daySum)
            }
            self.weeklyActivityData = tempWeekly

            // تحديث الواجهة في الخيط الرئيسي
            DispatchQueue.main.async {
                self.updateUI(successTotal: successTotal, totalMeals: totalMeals, today: todaySum, month: monthSum, allTime: allTimeSum)
            }
        }
    }

    private func updateUI(successTotal: Int, totalMeals: Int, today: Int, month: Int, allTime: Int) {
        // حماية من الـ nil outlets
        guard percentageLabel != nil else { return }
        
        self.percentageLabel.text = "\(Int(currentRate * 100))%"
        self.donutStatusDescriptionLabel.text = "\(successTotal) successful donations in total"
        self.totalMealsProcessedLabel.text = "\(totalMeals) meals"
        
        self.todayMealsLabel.text = "\(today) meals"
        self.monthlyMealsLabel.text = "\(month) meals"
        self.allTimeMealsLabel.text = "\(allTime) meals"
        
        setupCharts()
    }

    private func setupCharts() {
        drawDonutChart(percent: currentRate)
        drawAreaChart(data: weeklyActivityData)
    }
}

// MARK: - Drawing Logic (تبقى كما هي في كودك الأصلي مع تعديلات طفيفة للأمان)
extension AdminCollectorImpact {
    
    func drawDonutChart(percent: CGFloat) {
        guard donutContainerView != nil else { return }
        donutContainerView.layer.sublayers?.forEach { if $0 is CAShapeLayer { $0.removeFromSuperlayer() } }

        let center = CGPoint(x: donutContainerView.bounds.midX, y: donutContainerView.bounds.midY)
        let radius = (min(donutContainerView.bounds.width, donutContainerView.bounds.height) / 2) - 15
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)

        let bgLayer = CAShapeLayer()
        bgLayer.path = circularPath.cgPath
        bgLayer.strokeColor = UIColor.systemGray6.cgColor
        bgLayer.lineWidth = 12
        bgLayer.fillColor = UIColor.clear.cgColor
        donutContainerView.layer.insertSublayer(bgLayer, at: 0)

        let progressLayer = CAShapeLayer()
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor(red: 0.13, green: 0.45, blue: 0.25, alpha: 1.0).cgColor
        progressLayer.lineWidth = 12
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = percent // استخدام strokeEnd لعمل أنيميشن النسبة
        
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = 0 ; anim.toValue = percent; anim.duration = 1.0
        progressLayer.add(anim, forKey: "p")
        
        donutContainerView.layer.insertSublayer(progressLayer, at: 1)
    }

    func drawAreaChart(data: [CGFloat]) {
        guard areaChartContainer != nil, data.count > 0 else { return }
        areaChartContainer.layer.sublayers?.forEach { if $0 is CAShapeLayer || $0 is CAGradientLayer { $0.removeFromSuperlayer() } }
        
        let path = UIBezierPath()
        let width = areaChartContainer.bounds.width
        let height = areaChartContainer.bounds.height
        let maxValue = data.max() ?? 10
        
        let columnXPoint = { (column: Int) -> CGFloat in
            let spacing = width / CGFloat(max(1, data.count - 1))
            return CGFloat(column) * spacing
        }
        let columnYPoint = { (value: CGFloat) -> CGFloat in
            let y = height - (value / (maxValue == 0 ? 10 : maxValue) * height)
            return y
        }

        path.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(data[0])))
        for i in 1..<data.count {
            path.addLine(to: CGPoint(x: columnXPoint(i), y: columnYPoint(data[i])))
        }

        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = UIColor.systemGreen.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 3
        areaChartContainer.layer.addSublayer(lineLayer)

        let fillPath = UIBezierPath(cgPath: path.cgPath)
        fillPath.addLine(to: CGPoint(x: columnXPoint(data.count - 1), y: height))
        fillPath.addLine(to: CGPoint(x: columnXPoint(0), y: height))
        fillPath.close()

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = areaChartContainer.bounds
        gradientLayer.colors = [UIColor.systemGreen.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor]
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = fillPath.cgPath
        gradientLayer.mask = maskLayer
        areaChartContainer.layer.addSublayer(gradientLayer)
    }
}

