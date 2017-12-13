//
//  SettingsTableViewController.swift
//  TicTacToe
//
//  Created by Calvin on 9/7/17.
//  Copyright © 2017 Daniel Heredia. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    var gameManager: GameManager!
    var alertController: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()

        gameManager = (self.tabBarController as! TicTacToeTabBarController).gameManager
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.usernameLabel.text = gameManager.username
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView delegate methods

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView;
        
        header.textLabel?.textColor = UIColor.darkGray
        header.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.showTextAlert()
        } else if indexPath.row == 1 {
            self.openBridgefyPage()
        }
    }
    
    func showTextAlert() {
        self.alertController = UIAlertController(title: "Set the new username",
                                                 message: nil,
                                                 preferredStyle: .alert)
        
        self.alertController?.addTextField(configurationHandler: {[weak self] (textField : UITextField!) in
            textField.placeholder = "New username"
            textField.autocapitalizationType = .words
            textField.delegate = self
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction!) in
            self.clearTableSelection()
        }
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action : UIAlertAction!) in
            self.updateUsername(username: (self.alertController?.textFields?[0].text)!)
            self.clearTableSelection()
        }
        
        okAction.isEnabled = false
        
        self.alertController?.addAction(cancelAction)
        self.alertController?.addAction(okAction)
        
        self.alertController?.view.tintColor = APP_RED_COLOR
        
        self.present(self.alertController!, animated: true, completion: nil)
        
    }
    
    func updateUsername(username: String ) {
        UserDefaults.standard.setValue(username, forKey: StoredValues.username)
        gameManager.stop()
        gameManager.start(withUsername: username)
        self.usernameLabel.text = username;
    }
    
    func clearTableSelection() {
        guard let indexPath = self.tableView.indexPathForSelectedRow else {
            return
        }
        
        self.tableView .deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - UITextField delegate methods
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text as NSString? {
            let originalString = text.replacingCharacters(in: range, with: string)
            let cleanText = self.cleanText(string: originalString)
            
            self.alertController?.actions[1].isEnabled = cleanText.count > 0
        }
        
        return true
    }
    
    func cleanText(string: String) -> String {
        return string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func openBridgefyPage() {
        if let url = URL(string: "https://bridgefy.me") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

}
