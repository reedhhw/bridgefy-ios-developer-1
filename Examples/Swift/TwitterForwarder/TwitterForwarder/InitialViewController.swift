//
//  InitialViewController.swift
//  TicTacToe
//
//  Created by Bridgefy on 5/22/17.
//  Copyright © 2017 Bridgefy. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, UITextFieldDelegate {
    
    let prefix = "#"
    let maxCharacters = 20

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        addStyle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func addStyle() {
        //Textfield
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0.0,
                              y: nameTextField.frame.size.height - width,
                              width: nameTextField.frame.size.width,
                              height: width)
        border.borderWidth = width
        nameTextField.layer.addSublayer(border)
        nameTextField.layer.masksToBounds = true
        
        //Button
        startButton.layer.cornerRadius = 4.0
        
    }
    
    func addHashTagFormatIfNeeded(sender: UITextField) {
        guard let text = sender.text else {
            sender.text = prefix
            return
        }
        if text.count == 0 ||
            text.first != prefix.first {
            sender.text = "\(prefix)\(text)"
        }
    }
    
    func cleanTextFieldIfNeeded(sender: UITextField) {
        guard let text = sender.text else {
            sender.text = ""
            return
        }
        if text.first == prefix.first && text.count <= 1 {
            sender.text = ""
        }
    }
    
    @IBAction func didChangeText(sender: UITextField) {
        self.addHashTagFormatIfNeeded(sender: sender)
    }
    
    @IBAction func startApp(sender: UIButton) {
        if self.nameTextField.text == "" || self.nameTextField.text == prefix {
            self.askForHashtag()
        } else {
            self.sendStartEvent()
        }
    }
    
    private func sendStartEvent() {
        var username: String = nameTextField!.text!
        username = username.replacingOccurrences(of: prefix, with: "")
        UserDefaults.standard.setValue(username, forKey: StoredValues.username)
        let userInfo: [AnyHashable : Any] = [StoredValues.username: username]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNames.userReady),
                                        object: self,
                                        userInfo: userInfo)
        self.dismiss(animated: true)
    }
    
    private func askForHashtag() {
        nameTextField.becomeFirstResponder()
    }
    
    @IBAction func tap(gesture: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        self.cleanTextFieldIfNeeded(sender: self.nameTextField)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.cleanTextFieldIfNeeded(sender: self.nameTextField)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = string
        let existingChars = self.nameTextField.text?.count ?? 0
        if (existingChars + text.count) > maxCharacters {
            return false
        }
        let alreadyHasPound = self.nameTextField.text != nil && self.nameTextField.text!.contains(prefix.first!)
        if !alreadyHasPound && text.first == prefix.first {
            text.remove(at: text.startIndex)
        }

        let range = text.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted)
        return range == nil
    }

}
