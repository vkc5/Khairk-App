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
    }
    let Data:[DataStruct]=[
        DataStruct(title: "New Order", desc: "New Order Placed"),
        DataStruct(title: "2New Order", desc: "New Order Placed"),
        DataStruct(title: "3New Order", desc: "New Order Placed"),
        DataStruct(title: "4New Order", desc: "New Order Placed")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        list.dataSource = self
        list.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notificationData = Data[indexPath.row]
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell", for:     indexPath)as! AdminNotificationTableViewCell
        cell.title?.text=notificationData.title
        cell.body?.text=notificationData.desc
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
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
