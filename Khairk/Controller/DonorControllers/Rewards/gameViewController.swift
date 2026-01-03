//
//  gameViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 28/12/2025.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

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
    private let db = Firestore.firestore()
    private let xpPerDonation = 25
    private let maxXP = 100
    private let usedSpinsKey = "UserUsedSpinsCount"
    private let customGreen = UIColor(red: 7/255, green: 119/255, blue: 52/255, alpha: 1.0)
    
    private var currentLevel = 1
    private var currentXP = 0
    
    static var shouldLevelUp = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
        startFirebaseObservation()
        setupNotifications() // استدعاء دالة الإشعارات واللمس
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if gameViewController.shouldLevelUp {
            updateUI()
            gameViewController.shouldLevelUp = false
        }
    }
}

// MARK: - Firebase Logic
extension gameViewController {
    private func startFirebaseObservation() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("donations")
            .whereField("donorId", isEqualTo: uid)
            .whereField("status", in: ["accepted", "approved", "collected"])
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self, let documents = querySnapshot?.documents else { return }
                self.calculateGameProgress(totalDonations: documents.count)
            }
    }
    
    private func calculateGameProgress(totalDonations: Int) {
        let rawTotalXP = totalDonations * xpPerDonation
        let usedSpins = UserDefaults.standard.integer(forKey: usedSpinsKey)
        
        // المستوى: يعتمد على إجمالي التبرعات ولا ينقص
        self.currentLevel = (rawTotalXP / maxXP) + 1
        
        // النقاط المتبقية: هي التي تُخصم بعد السبين
        let totalSpentXP = usedSpins * maxXP
        self.currentXP = max(0, rawTotalXP - totalSpentXP)
        
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
}

// MARK: - UI Management
extension gameViewController {
    private func updateUI() {
        statusLabel.text = "Level \(currentLevel)  \(currentXP)/\(maxXP) EXP"
        let progress = Float(currentXP) / Float(maxXP)
        xpProgressBar.setProgress(progress, animated: true)
        
        updatePlantEvolution()
        toggleSpinButton(enabled: currentXP >= maxXP)
        
        self.view.bringSubviewToFront(InfoButton)
        self.view.bringSubviewToFront(SpinButton)
    }
    
    private func updatePlantEvolution() {
        seedImage.isHidden = (currentLevel != 1)
        sproutImage.isHidden = !(currentLevel >= 2 && currentLevel < 4)
        treeImage.isHidden = (currentLevel < 4)
    }
    
    private func toggleSpinButton(enabled: Bool) {
        SpinButton.isEnabled = enabled
        if enabled {
            SpinButton.backgroundColor = customGreen
            startPulseAnimation()
        } else {
            SpinButton.backgroundColor = customGreen.withAlphaComponent(0.2)
            stopPulseAnimation()
        }
    }
}

// MARK: - Actions & Notifications
extension gameViewController {
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLevelUpNotification), name: NSNotification.Name("UserLeveledUp"), object: nil)
        
        // تم إصلاح الخطأ هنا: تعريف tapGesture بشكل صحيح
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(forceInfoTap))
        InfoButton.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleLevelUpNotification() {
        let currentSpins = UserDefaults.standard.integer(forKey: usedSpinsKey)
        UserDefaults.standard.set(currentSpins + 1, forKey: usedSpinsKey)
        
        gameViewController.shouldLevelUp = true
        updateUI()
    }
    
    @IBAction func SpinButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToWheel", sender: nil)
    }
    
    @objc private func forceInfoTap() {
        if let infoVC = storyboard?.instantiateViewController(withIdentifier: "InfoVC") {
            infoVC.modalPresentationStyle = .overFullScreen
            self.present(infoVC, animated: true)
        }
    }
}

// MARK: - Setup & Animations
extension gameViewController {
    private func setupInitialUI() {
        SpinButton.layer.cornerRadius = 20
        [seedImage, sproutImage, treeImage].forEach { $0?.isUserInteractionEnabled = false }
    }
    
    private func startPulseAnimation() {
        if SpinButton.layer.animation(forKey: "pulse") == nil {
            let pulse = CABasicAnimation(keyPath: "transform.scale")
            pulse.duration = 0.6; pulse.fromValue = 1.0; pulse.toValue = 1.08
            pulse.autoreverses = true; pulse.repeatCount = .infinity
            SpinButton.layer.add(pulse, forKey: "pulse")
        }
    }
    
    private func stopPulseAnimation() {
        SpinButton.layer.removeAnimation(forKey: "pulse")
    }
}
