//
//  ReceivedNotificationsViewController.swift
//  BroadcastAlert
//
//  Created by Daniel Heredia on 8/2/16.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit

let notifsFile = "notifs.txt"

open class ReceivedNotificationsViewController: UITableViewController {
    
    fileprivate var notifications: NSMutableArray

    public required init?(coder aDecoder: NSCoder) {
        //Load previous notifications
        self.notifications = ReceivedNotificationsViewController.loadNotifications()
        super.init(coder: aDecoder)
        
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Info update interface methods
    
    open func addNotificationDictionary(_ dictionary: [AnyHashable: Any], fromUUID uuid: String) {
            //Process the data sent by other peer.
            ReceivedNotificationsViewController.addNotificationToFile(dictionary, fromUUID: uuid)
            self.refreshData()
        }
        
    func refreshData() {
        self.notifications = ReceivedNotificationsViewController.loadNotifications()
        self.tableView.reloadData()
    }

    // MARK: Table view data source
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
        let notification: Notification = self.notifications.object(at: indexPath.item) as! Notification
        let numberLabel = cell.contentView.viewWithTag(1001) as! UILabel
        let fromLabel = cell.contentView.viewWithTag(1002) as! UILabel
        let dateLabel = cell.contentView.viewWithTag(1003) as! UILabel
        numberLabel.text = "Alert number: \(notification.number)"
        fromLabel.text = "From user: \(notification.senderName) (\(notification.senderId))"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let dateString = dateFormatter.string(from: notification.date as Date)
        dateLabel.text = "Time: \(dateString)"
        return cell
    }

    // MARK: Clumsy data management.
    
    // The methods in this section are not relevant to show
    // the BFTransmitter functionality.

    class func addNotificationToFile(_ dictionary: [AnyHashable: Any], fromUUID uuid: String) {
        let notification = Notification()
        notification.number = (dictionary["number"] as! NSNumber).intValue
        notification.senderId = String(uuid[..<uuid.index(uuid.startIndex, offsetBy: 5)])
        notification.senderName = dictionary["device_name"] as! String
        let doubleValue = (dictionary["date_sent"] as! NSNumber).doubleValue / 1000
        let date = Date(timeIntervalSince1970: doubleValue)
        notification.date = date
        let notifications: NSMutableArray = self.loadNotifications()
        notifications.insert(notification, at: 0)
        let filePath = fullPathForFile(notifsFile)
        let data = NSKeyedArchiver.archivedData(withRootObject: notifications)
        try? data.write(to: URL(fileURLWithPath: filePath), options: [.atomic])
    }
    
    class func loadNotifications() -> NSMutableArray {
        let filePath = fullPathForFile(notifsFile)
        let data: Data? = try? Data(contentsOf: URL(fileURLWithPath: filePath))
        if (data != nil)
        {
            return NSKeyedUnarchiver.unarchiveObject(with: data!) as! NSMutableArray
        } else
        {
            return NSMutableArray()
        }
    }

    class func fullPathForFile(_ file: String) -> String {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        return url.appendingPathComponent(file).path
    }
}
