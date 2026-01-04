//
//  CollectorNotificatinSettingsViewController.swift
//  Khairk
//
//  Created by BP-36-213-17 on 04/01/2026.
//

import UIKit

class CollectorNotificatinSettingsViewController: UIViewController {

    @IBOutlet weak var muteNotifaction: UISwitch!
    @IBOutlet weak var sound: UISwitch!
    @IBOutlet weak var vibrate: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSettings()
        print("""
                🐞 CURRENT SETTINGS:
                Mute: \(muteNotifaction.isOn)
                Sound: \(sound.isOn)
                Vibrate: \(vibrate.isOn)
                ---------------------
                """)
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func muteChanged(_ sender: UISwitch) {
        print("Mute notifaction switch changed: \(sender.isOn)")
        UserDefaults.standard.set(sender.isOn, forKey: "mute")
        applyMuteLogic()
    }
    
    @IBAction func soundChanged(_ sender: UISwitch) {
        print("Sound notifaction switch changed: \(sender.isOn)")
        UserDefaults.standard.set(sender.isOn, forKey: "sound")
    }
    
    @IBAction func vibrateChanged(_ sender: UISwitch) {
        print("Vibrate notifaction switch changed: \(sender.isOn)")
        UserDefaults.standard.set(sender.isOn, forKey: "vibrate")
    }
    
    
    func applyMuteLogic() {
        let isMuted = muteNotifaction.isOn

        sound.isEnabled = !isMuted
        vibrate.isEnabled = !isMuted

        if isMuted {
            sound.setOn(false, animated: true)
            vibrate.setOn(false, animated: true)
            UserDefaults.standard.set(false, forKey: "sound")
            UserDefaults.standard.set(false, forKey: "vibrate")
        }
    }

        
    func loadSettings() {
        muteNotifaction.isOn = UserDefaults.standard.bool(forKey: "mute")
        sound.isOn = UserDefaults.standard.bool(forKey: "sound")
        vibrate.isOn = UserDefaults.standard.bool(forKey: "vibrate")
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
