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
    @IBOutlet weak var areaChartContainer: UIView! // الحاوية التي رسمت فيها الأرقام والأيام
    
    @IBOutlet weak var todayMealsLabel: UILabel!
    @IBOutlet weak var monthlyMealsLabel: UILabel!
    @IBOutlet weak var allTimeMealsLabel: UILabel!

    // MARK: - Properties
    private let db = Firestore.firestore()
    // بيانات تجريبية للمنحنى (تمثل الارتفاعات من الأحد للسبت)
    var monthlyActivityData: [CGFloat] = [20, 50, 40, 80, 60, 90, 70]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // تشغيل الرسوم البيانية عند ظهور الشاشة
        setupCharts()
    }
    
    private func setupCharts() {
        // 1. رسم الدائرة العلوية (بنسبة 100% كما في تصميمك)
        drawDonutChart(percent: 1.0)
        
        // 2. رسم المنحنى السفلي (Area Chart)
        drawAreaChart(data: monthlyActivityData)
    }
}

// MARK: - Drawing Logic (Donut & Area Charts)
extension AdminCollectorImpact {
    
    // دالة رسم الدائرة العلوية
    func drawDonutChart(percent: CGFloat) {
        donutContainerView.layer.sublayers?.forEach { if $0 is CAShapeLayer { $0.removeFromSuperlayer() } }

        let center = CGPoint(x: donutContainerView.bounds.midX, y: donutContainerView.bounds.midY)
        let radius = (donutContainerView.bounds.width / 2) - 15
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)

        // الدائرة الرمادية (الخلفية)
        let bgLayer = CAShapeLayer()
        bgLayer.path = circularPath.cgPath
        bgLayer.strokeColor = UIColor.systemGray6.cgColor
        bgLayer.lineWidth = 12
        bgLayer.fillColor = UIColor.clear.cgColor
        donutContainerView.layer.insertSublayer(bgLayer, at: 0)

        // الدائرة الخضراء (التقدم)
        let progressLayer = CAShapeLayer()
        let endAngle = (-CGFloat.pi / 2) + (2 * CGFloat.pi * percent)
        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: endAngle, clockwise: true)
        
        progressLayer.path = progressPath.cgPath
        progressLayer.strokeColor = UIColor(red: 0.13, green: 0.45, blue: 0.25, alpha: 1.0).cgColor
        progressLayer.lineWidth = 12
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = 0 ; anim.duration = 1.0
        progressLayer.add(anim, forKey: "p")
        
        donutContainerView.layer.insertSublayer(progressLayer, at: 1)
    }

    // دالة رسم المنحنى المظلل (Area Chart)
    func drawAreaChart(data: [CGFloat]) {
        areaChartContainer.layer.sublayers?.forEach { if $0 is CAShapeLayer || $0 is CAGradientLayer { $0.removeFromSuperlayer() } }
        
        let path = UIBezierPath()
        let width = areaChartContainer.bounds.width
        let height = areaChartContainer.bounds.height
        let columnXPoint = { (column: Int) -> CGFloat in
            let spacing = width / CGFloat(data.count - 1)
            return CGFloat(column) * spacing
        }
        let columnYPoint = { (value: CGFloat) -> CGFloat in
            let y = height - (value / (data.max() ?? 100) * height)
            return y
        }

        // رسم الخط المنحني
        path.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(data[0])))
        for i in 1..<data.count {
            path.addLine(to: CGPoint(x: columnXPoint(i), y: columnYPoint(data[i])))
        }

        // إنشاء طبقة الخط (المنحنى)
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = UIColor.systemGreen.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 3
        areaChartContainer.layer.addSublayer(lineLayer)

        // إنشاء التظليل (Area Fill) تحت الخط
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
