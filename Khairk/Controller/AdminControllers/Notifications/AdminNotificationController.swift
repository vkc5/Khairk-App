//
//  AdminNotificationController.swift
//  Khairk
//
//  Created by BP-19-130-16 on 21/12/2025.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AdminNotificationController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var list: UITableView!
    struct DataStruct{
        var title:String
        var desc:String
        var isRead:Bool
        var date:Date
    }
    var notifications:[Notification.AppNotification]=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        
        setupTableView()
        fetchNotifications()

        
        // Do any additional setup after loading the view.
    }
    
    private func setupTableView() {
        list.dataSource = self
        list.delegate = self
        
        list.rowHeight = UITableView.automaticDimension
        list.estimatedRowHeight = 100
    }
    
    private func fetchNotifications() {
        let db = Firestore.firestore()
        
        db.collection("notifications").getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No notifications found")
                return
            }
            
            var fetchedNotifications: [Notification.AppNotification] = []
            
            for document in documents {
                print("Doc ID:", document.documentID, "Data:", document.data())
                let data = document.data()
                if let notification = Notification.AppNotification(id: document.documentID, dictionary: data) {
                    fetchedNotifications.append(notification)
                }else {
                    print("Failed to parse notification:", data)
                }
            }
            print("Fetched notifications count:", fetchedNotifications.count)
            self.notifications = fetchedNotifications
            
            // Reload table view on main thread
            DispatchQueue.main.async {
                self.list.reloadData()
            }
        }
    }

    
    @IBAction func deleteAllBtn(_ sender: Any) {
        let alert = UIAlertController(title: "Delete All", message: "Are you sure you want to delete all notifications?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                guard !self.notifications.isEmpty else {
                    let emptyAlert = UIAlertController(title: "No notifications", message: "There are no notifications to delete.", preferredStyle: .alert)
                    emptyAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(emptyAlert, animated: true, completion: nil)
                    return
                }
                self.notifications.removeAll()
                self.list.reloadData()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notificationData = notifications[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)as! AdminNotificationTableViewCell
        
        cell.notificationContainer.layer.cornerRadius = 12
        cell.notificationContainer.layer.borderWidth = 1
        
        if notificationData.isRead{
            cell.notificationContainer.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            cell.notificationContainer.layer.borderColor = UIColor.mainBrand500.cgColor
            cell.notificationContainer.backgroundColor = UIColor.mainBrand50
        }
        
        cell.titleLabel?.text=notificationData.title
        cell.bodyLabel?.text=notificationData.body
        cell.dateLabel?.text=notificationData.timestamp.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notifications.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let notification = self.notifications[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.notifications.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        var actions: [UIContextualAction] = [deleteAction]
        
        if !notification.isRead {
            let markAsReadAction = UIContextualAction(style: .normal, title: "Mark as Read") { (action, view, completionHandler) in
                let db = Firestore.firestore()
                let notification = self.notifications[indexPath.row]
                db.collection("notifications").document(notification.id).updateData([
                           "isRead": 1
                       ]) { error in
                           if let error = error {
                               print("Failed to mark as read: \(error)")
                           } else {
                               self.notifications[indexPath.row].isRead = true
                               tableView.reloadRows(at: [indexPath], with: .automatic)
                           }
                       }

                completionHandler(true)
            }
            markAsReadAction.image = UIImage(systemName: "checkmark")
            markAsReadAction.backgroundColor = .systemBlue
            actions.append(markAsReadAction)
        }
       
        return UISwipeActionsConfiguration(actions: actions)
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let notification = self.notifications[indexPath.row]
        if !notification.isRead {
            let markAsReadAction = UIContextualAction(style: .normal, title: "Mark as Read") { (action, view, completionHandler) in
                let db = Firestore.firestore()
                let notification = self.notifications[indexPath.row]
                db.collection("notifications").document(notification.id).updateData([
                           "isRead": 1
                       ]) { error in
                           if let error = error {
                               print("Failed to mark as read: \(error)")
                           } else {
                               self.notifications[indexPath.row].isRead = true
                               tableView.reloadRows(at: [indexPath], with: .automatic)
                           }
                       }

                completionHandler(true)
            }
            markAsReadAction.image = UIImage(systemName: "checkmark")
            markAsReadAction.backgroundColor = .systemBlue
            return UISwipeActionsConfiguration(actions: [markAsReadAction])
        }
        return nil
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
