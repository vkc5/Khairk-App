//
//  AdminBroadcastViewController.swift
//  Khairk
//
//  Created by BP-36-201-18 on 02/12/2025.
//

import UIKit
import Firebase
import FirebaseStorage

class AdminBroadcastViewController: UIViewController {

    @IBOutlet weak var recipientSegment: UISegmentedControl!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Send Massage (Broadcast)"

        // Do any additional setup after loading the view.
    }
    

    @IBAction func sendNotificationBtn(_ sender: UIButton) {
        guard formValidate() else { return }
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let body = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let selectedIndex = recipientSegment.selectedSegmentIndex
        var recipientRole = ""
        
        switch selectedIndex {
            case 0: recipientRole = "all"
            case 1: recipientRole = "donor"
            case 2: recipientRole = "collector"
            default: recipientRole = "all"
        }
        
        let alert = UIAlertController(
            title: "Confirm Notification",message: "Title: \(title)\n\nMessage: \(body)\n\nSend to: \(recipientRole.capitalized)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                let db = Firestore.firestore()
                var query: Query = db.collection("users")
                if recipientRole != "all" {
                    query = query.whereField("role", isEqualTo: recipientRole)
                }

                query.getDocuments { querySnapshot, error in
                    if let error = error {
                        print("Error fetching users: \(error.localizedDescription)")
                        return
                    }
                    guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                        print("No users found for role: \(recipientRole)")
                        return
                    }
                    for document in documents {
                        let userId = document.documentID
                        let notification = Notification()
                        notification.save(title: title, body: body, userId: userId)
                    }
                }
                DispatchQueue.main.async {
                    self.titleTextField.text = ""
                    self.messageTextField.text = ""
                    self.recipientSegment.selectedSegmentIndex = UISegmentedControl.noSegment
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
    }
    
    func formValidate() -> Bool {
        let title = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let body = messageTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let selectedIndex = recipientSegment.selectedSegmentIndex
        
        var message = ""
        if selectedIndex == UISegmentedControl.noSegment {
            message += "Please select a recipient.\n"
        }
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
