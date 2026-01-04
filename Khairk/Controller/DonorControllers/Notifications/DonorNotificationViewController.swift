//
//  DonorNotificationViewController.swift
//  Khairk
//
//  Created by BP-36-213-17 on 04/01/2026.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class DonorNotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    let refreshControl = UIRefreshControl()
    
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
        refreshControl.addTarget(self, action: #selector(refreshNotificationsData(_:)), for: .valueChanged)
        list.refreshControl = refreshControl
        refreshControl.tintColor = UIColor.mainBrand500
        
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
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection("notifications").whereField("userId", isEqualTo: uid).order(by: "createdAt", descending: true).getDocuments { [weak self] querySnapshot, error in
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
                print("ID:", document.documentID, "Data:", document.data())
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
                self.refreshControl.endRefreshing()
                self.list.reloadData()
                self.updateEmptyState()
            }
        }
    }

    
    @IBAction func deleteAllBtn(_ sender: Any) {
        let alert = UIAlertController(title: "Delete All", message: "Are you sure you want to delete all notifications?", preferredStyle: .alert)
            
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            guard !self.notifications.isEmpty else {
                print("ℹ️ No notifications to delete")
                return
            }
            
            let db = Firestore.firestore()
            let batch = db.batch()
            
            print("🗑 Deleting ALL notifications:", self.notifications.count)
            
            for notification in self.notifications {
                let ref = db.collection("notifications").document(notification.id)
                batch.deleteDocument(ref)
            }
            
            batch.commit { error in
                if let error = error {
                    print("❌ Batch delete failed:", error.localizedDescription)
                    return
                }
                
                print("✅ All notifications deleted from Firestore")
                
                self.notifications.removeAll()
                self.list.reloadData()
                self.updateEmptyState()
            }
        }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notificationData = notifications[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DonorNotificationTableViewCell
        
        cell.notificationContainer.layer.cornerRadius = 12
        cell.notificationContainer.layer.borderWidth = 1
        
        if notificationData.isRead{
            cell.notificationContainer.layer.borderColor = UIColor.systemGray4.cgColor
            cell.notificationContainer.backgroundColor = .clear
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
            self.updateEmptyState()
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let notification = self.notifications[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completionHandler) in
            
            let notification = self.notifications[indexPath.row]
            let db = Firestore.firestore()
            
            print("🗑 Deleting notification:", notification.id)
            
            db.collection("notifications")
                .document(notification.id)
                .delete { error in
                    
                    if let error = error {
                        print("❌ Failed to delete:", error.localizedDescription)
                        completionHandler(false)
                        return
                    }
                    
                    print("✅ Deleted from Firestore")
                    
                    self.notifications.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.updateEmptyState()
                    
                    completionHandler(true)
                }
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
    private func updateEmptyState() {
        if notifications.isEmpty {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: list.bounds.size.width, height: list.bounds.size.height))
            
            noDataLabel.text = "You have no notifications yet."
            
            noDataLabel.textColor = .gray
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 0
            noDataLabel.font = .systemFont(ofSize: 16, weight: .medium)
            
            // Setting the backgroundView of your table 'list'
            list.backgroundView = noDataLabel
            list.separatorStyle = .none // Hides line separators when empty
        } else {
            list.backgroundView = nil
            list.separatorStyle = .singleLine
        }
    }
    
    @objc private func refreshNotificationsData(_ sender: Any) {
        fetchNotifications()
    }
    
    @IBAction func goToNotificationSettings(_ sender: Any) {
        let storyboard = UIStoryboard(name: "DonorProfile", bundle: nil)
        let mapVC = storyboard.instantiateViewController(withIdentifier: "DonorNotificatinSettingsVC")

        mapVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(mapVC, animated: true)
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
