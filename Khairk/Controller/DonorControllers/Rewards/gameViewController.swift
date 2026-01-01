//
//  gameViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 28/12/2025.
//
import UIKit

class gameViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var seedImage: UIImageView!
    @IBOutlet weak var sproutImage: UIImageView!
    @IBOutlet weak var treeImage: UIImageView!
    @IBOutlet weak var xpProgressBar: UIProgressView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var InfoButton: UIButton!
    @IBOutlet weak var SpinButton: UIButton!
    
    // MARK: - Properties
    static var shouldLevelUp = false
    var currentLevel = 1
    var currentXP = 100 // لغرض الاختبار ممتلئ
    let maxXP = 100
    let customGreen = UIColor(red: 7/255, green: 119/255, blue: 52/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. إعداد الواجهة الأساسية
        setupUI()
        
        // 2. إضافة "مراقب لمس" يدوي كحل لمشكلة حجب الطبقات
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(forceInfoTap))
        InfoButton.addGestureRecognizer(tapGesture)
        
        // 3. الاستماع لإشعار زيادة المستوى عند العودة من العجلة
        NotificationCenter.default.addObserver(self, selector: #selector(handleLevelUp), name: NSNotification.Name("UserLeveledUp"), object: nil)
    }
    
    @objc func forceInfoTap() {
        print("✅ تم رصد اللمسة عن طريق الـ Gesture Recognizer")
        openInfoPage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // التحقق من حالة الترقية فور ظهور الشاشة
        if gameViewController.shouldLevelUp {
            executeLevelUp()
            gameViewController.shouldLevelUp = false
        } else {
            updateUI()
        }
    }
    
    func setupUI() {
        SpinButton.layer.cornerRadius = 20
        
        // تعطيل التفاعل مع الصور لضمان وصول اللمس للأزرار خلفها
        seedImage.isUserInteractionEnabled = false
        sproutImage.isUserInteractionEnabled = false
        treeImage.isUserInteractionEnabled = false
        
        // التأكد من أن الزر مفعّل
        InfoButton.isUserInteractionEnabled = true
        
        // إحضار الأزرار للأمام (فوق الصور)
        self.view.bringSubviewToFront(InfoButton)
        self.view.bringSubviewToFront(SpinButton)
        
        updateUI()
    }

    // الدالة الأصلية للأكشن المربوط بالزر
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        openInfoPage()
    }

    func openInfoPage() {
        // تم إصلاح القوس المفقود هنا
        if let infoVC = storyboard?.instantiateViewController(withIdentifier: "InfoVC") as? InfoViewController {
            infoVC.modalPresentationStyle = .overFullScreen
            infoVC.modalTransitionStyle = .crossDissolve
            self.present(infoVC, animated: true, completion: nil)
        } else {
            print("❌ خطأ: لم يتم العثور على Storyboard ID باسم InfoVC")
        }
    }

    @objc func handleLevelUp() {
        gameViewController.shouldLevelUp = true
    }
    
    func executeLevelUp() {
        currentLevel += 1
        currentXP = 0
        updateUI()
        print("🎉 مبروك! انتقلت للمستوى التالي: \(currentLevel)")
    }
    
    func updateUI() {
        // تحديث النصوص والبار
        statusLabel.text = "Level \(currentLevel)  \(currentXP)/\(maxXP) EXP"
        let progress = Float(currentXP) / Float(maxXP)
        xpProgressBar.setProgress(progress, animated: true)
        
        // منطق إخفاء وإظهار الصور
        seedImage.isHidden = (currentLevel != 1)
        sproutImage.isHidden = !(currentLevel >= 2 && currentLevel < 5)
        treeImage.isHidden = (currentLevel < 5)
        
        // التأكد من بقاء زر المعلومات في المقدمة في كل تحديث
        self.view.bringSubviewToFront(InfoButton)
        
        // منطق زر السبين
        if currentXP >= maxXP {
            SpinButton.isEnabled = true
            SpinButton.backgroundColor = customGreen
            SpinButton.setTitle("Spin the wheel", for: .normal)
        } else {
            SpinButton.isEnabled = false
            SpinButton.backgroundColor = customGreen.withAlphaComponent(0.2)
            SpinButton.setTitle("Donate more to spin", for: .normal)
        }
    }

    @IBAction func SpinButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToWheel", sender: nil)
    }
}
