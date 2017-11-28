//
//  ComposeViewController.swift
//  TwitterForwarder
//
//  Created by Danno on 7/13/17.
//  Copyright © 2017 Daniel Heredia. All rights reserved.
//

import UIKit

protocol ComposeDelegate: class {
    func composeController(_ composeController: ComposeViewController, didCreateTweet tweetText: String)
}

class ComposeViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var composeContainerView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var composeTextView: UITextView!
    @IBOutlet weak var charactersLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    weak var delegate: ComposeDelegate?
    var gradientLayer: CAGradientLayer!
    let characterLimit = 140
    var username: String = ""
    var submitColor: UIColor!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addContainerLayer()
        composeContainerView.layer.cornerRadius = 5.0
        submitButton.layer.cornerRadius = 2.0
        composeTextView.layer.cornerRadius = 1.0
        composeTextView.delegate = self
        submitColor = submitButton.backgroundColor
        performTextCheck()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.composeTextView.becomeFirstResponder()
    }
    
    func addContainerLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.height, height: self.composeContainerView.frame.width)
        let firstColor = #colorLiteral(red: 0.9103977084, green: 0.9103977084, blue: 0.9103977084, alpha: 1)
        let secondColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        self.composeContainerView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func cancelCompose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func submit(_ sender: Any) {
        self.delegate?.composeController(self, didCreateTweet: composeTextView.text)
        self.dismiss(animated: true)
    }
    
    @IBAction func endEdition(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    func performTextCheck() {
        let remainingCharacters = self.characterLimit - self.composeTextView.text.count - self.username.count - 2
        if remainingCharacters >= 0 && composeTextView.text.count > 0{
            self.charactersLabel.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            self.submitButton.isEnabled = true
            self.submitButton.backgroundColor = self.submitColor
        } else {
            self.charactersLabel.textColor = #colorLiteral(red: 0.9337880015, green: 0.1666890383, blue: 0.2225230038, alpha: 1)
            self.submitButton.isEnabled = false
            self.submitButton.backgroundColor = #colorLiteral(red: 0.9103977084, green: 0.9103977084, blue: 0.9103977084, alpha: 1)
        }
        self.charactersLabel.text = "\(remainingCharacters) characters left"
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.view
    }
}

extension ComposeViewController: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        self.placeholderLabel.isHidden = self.composeTextView.text.count > 0
        performTextCheck()
    }
    
}
