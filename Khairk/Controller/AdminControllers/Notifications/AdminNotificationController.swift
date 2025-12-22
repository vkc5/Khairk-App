//
//  AdminNotificationController.swift
//  Khairk
//
//  Created by BP-19-130-16 on 21/12/2025.
//

import UIKit

class AdminNotificationController: UIViewController , UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var list: UITableView!
    struct DataStruct{
        var title:String
        var desc:String
        var isRead:Bool
        var date:Date
    }
    var Data:[DataStruct]=[
        DataStruct(title: "New Order", desc: "New Order Placed", isRead: false, date: Date()),
        DataStruct(title: "2New Order", desc: "New Order Placed", isRead: false, date: Date()),
        DataStruct(title: "3New Order", desc: "New Order PlacedNew Order PlacedNew Order PlacedNew Order PlacedNew Order PlacedNew Order PlacedNew Order PlacedNew Order PlacedNew Order PlacedNew Order PlacedNew Order Placed" ,isRead: true, date: Date()),
        DataStruct(title: "4New Order", desc: "New Order Placed", isRead: true, date: Date())
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        list.dataSource = self
        list.delegate = self
        
        list.rowHeight = UITableView.automaticDimension
        list.estimatedRowHeight = 100

        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notificationData = Data[indexPath.row]
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
        cell.bodyLabel?.text=notificationData.desc
        cell.dateLabel?.text=notificationData.date.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            self.Data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        let markAsReadAction = UIContextualAction(style: .normal, title: "Mark as Read") { (action, view, completionHandler) in
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        markAsReadAction.image = UIImage(systemName: "checkmark")
        markAsReadAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [deleteAction,markAsReadAction])
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let markAsReadAction = UIContextualAction(style: .normal, title: "Mark as Read") { (action, view, completionHandler) in
            completionHandler(true)
        }
        markAsReadAction.image = UIImage(systemName: "checkmark")
        markAsReadAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [markAsReadAction])
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
