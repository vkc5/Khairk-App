//
//  AdminUserManagementSendMassageController.swift
//  Khairk
//
//  Created by BP-36-213-17 on 01/01/2026.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AdminUserManagementSendMassageController: UIViewController {
    var donorID: String?
    var donorName: String?
    var donorImage: UIImage?
    var donorJoinDateString: String?
    @IBOutlet weak var donorImageView: UIImageView!
    @IBOutlet weak var donorNameLabel: UILabel!
    @IBOutlet weak var donorJoinDateLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    private func setupUI() {
        title = "Message Donor"
        donorNameLabel.text = donorName
        donorImageView.image = donorImage
        donorJoinDateLabel.text = donorJoinDateString
        
        container.layer.cornerRadius = 12
        donorImageView.layer.cornerRadius = donorImageView.frame.width / 2
        donorImageView.clipsToBounds = true
        donorImageView.tintColor = .mainBrand500
        donorImageView.contentMode = .scaleAspectFill
    }

    @IBAction func sendMessageBtn(_ sender: Any) {
        guard formValidate() else { return }
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let body = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let name = self.donorName ?? "Donor"
        

        
        let alert = UIAlertController(
            title: "Confirm Notification",message: "Title: \(title)\nMessage: \(body)\nSend to: \(name)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                if let id = self.donorID {
                    Notification.shared.save(
                        title: title,
                        body: body,
                        userId: id,
                        makeLocalNotification: true
                    )
                    DispatchQueue.main.async {
                        self.titleTextField.text = ""
                        self.messageTextField.text = ""
                    }
                    
                } else {
                    print("Error: Donor ID is missing")
                }

                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
    }
    
    func formValidate() -> Bool {
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let body = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
             
        var message = ""

        if title.isEmpty {
            message += "Please enter a title.\n"
            titleTextField.layer.borderColor = UIColor.red.cgColor
            titleTextField.layer.borderWidth = 1
            titleTextField.layer.cornerRadius = 5
        }else{
            titleTextField.layer.borderColor = UIColor.gray.cgColor
            titleTextField.layer.borderWidth = 1
            titleTextField.layer.cornerRadius = 5
        }
        if body.isEmpty {
            message += "Please enter a message body."
            messageTextField.layer.borderColor = UIColor.red.cgColor
            messageTextField.layer.borderWidth = 1
            messageTextField.layer.cornerRadius = 5
        }else{
            messageTextField.layer.borderColor = UIColor.gray.cgColor
            messageTextField.layer.borderWidth = 1
            messageTextField.layer.cornerRadius = 5
        }
        
        if !message.isEmpty {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
                return false
        }
        
        return true
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
