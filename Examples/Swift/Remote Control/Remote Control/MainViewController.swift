//
//  MainViewController.swift
//  Remote Control
//
//  Created by Calvin on 7/11/17.
//  Copyright © 2017 Bridgefy Inc. All rights reserved.
//

import UIKit
import BFTransmitter
import AVFoundation

let kLastID = "lastId"
let kCommandKey = "command"
let kIdKey = "id"
let kImageKey = "image"
let kColorKey = "color"
let kTextKey = "text"

enum Comand : Int {
    case image = 1
    case color
    case flashlight
    case text
}

class MainViewController: UIViewController, BFTransmitterDelegate {
    
    let images = ["ad", "sports", "map", "concert"]
    var transmitter: BFTransmitter?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil);
        
        // Transmitter initialization
        BFTransmitter.setLogLevel(.error)
        self.transmitter = BFTransmitter(apiKey: "YOUR API KEY")
        self.transmitter?.delegate = self
        self.transmitter?.isBackgroundModeEnabled = true
        self.transmitter?.start()
        
        // Instruction for the user
        let clientMessage = "Client Screen\n\n Long press with one finger to go to the admin panel. This will allow you to send commands to nearby devices."
        self.showText(clientMessage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func longPressDetected(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.showAdminDialog()
        }
    }
    
    func showAdminDialog() {
        let alertController = UIAlertController(title: "Do you want to become an admin?",
                                                message: "",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.performSegue(withIdentifier: "showAdminView", sender: self)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAdminView" {
            let adminVC = segue.destination as! AdminViewTabBarController
            adminVC.mvc = self
        }
    }
    
    public func send(object: Any?, sender: Any) {
        var dict: [String: Any] = Dictionary.init()
        
        dict[kIdKey] = floor(Date.init().timeIntervalSince1970 * 1000) as Any
        
        if sender is ImagePickerViewController {
            dict[kCommandKey] = Comand.image.rawValue as Any
            dict[kImageKey] = object
        } else if sender is ColorPickerViewController {
            dict[kCommandKey] = Comand.color.rawValue as Any
            dict[kColorKey] = object
        } else if sender is FlashlightViewController {
            dict[kCommandKey] = Comand.flashlight.rawValue as Any
        } else if sender is InputTextViewController {
            dict[kCommandKey] = Comand.text.rawValue as Any
            dict[kTextKey] = object
        } else {
            print("ERROR: Unknown sender")
            return;
        }
        
        let options: BFSendingOption = [.broadcastReceiver, .meshTransmission]
        
        do {
            try self.transmitter?.send(dict, toUser: nil, options: options)
        } catch let err as NSError {
            print("ERROR: \(err.localizedDescription)")
        }
        
        
    }
    
    // MARK: - BFTransmitterDelegate
    
    public func transmitter(_ transmitter: BFTransmitter, meshDidAddPacket packetID: String) {
        
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didReachDestinationForPacket packetID: String) {
        //Mesh packet reached destiny (no always invoked)
    }
    
    public func transmitter(_ transmitter: BFTransmitter, meshDidStartProcessForPacket packetID: String) {
        //A message entered in the mesh process (was added).
        // Just called when the option BFSendingOptionFullTransmission was used.
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didSendDirectPacket packetID: String) {
        //A direct message was sent
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didFailForPacket packetID: String, error: Error?) {
        //A direct message transmission failed.
    }
    
    public func transmitter(_ transmitter: BFTransmitter, meshDidDiscardPackets packetIDs: [String]) {
        //A mesh message was discared and won't still be transmitted.
        
    }
    
    public func transmitter(_ transmitter: BFTransmitter, meshDidRejectPacketBySize packetID: String) {
        print("The packet \(packetID) was rejected from mesh because it exceeded the limit size.");
    }
    
    public func transmitter(_ transmitter: BFTransmitter,
                            didReceive dictionary: [String : Any]?,
                            with data: Data?,
                            fromUser user: String,
                            packetID: String,
                            broadcast: Bool,
                            mesh: Bool) {
        // A dictionary was received by BFTransmitter.
        
        self.processReceived(dict: dictionary)
        
        
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didDetectConnectionWithUser user: String) {
        //A connection was detected (no necessarily secure)
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didDetectDisconnectionWithUser user: String) {
        // A disconnection was detected.
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didFailAtStartWithError error: Error)
    {
        print("An error occurred at start: \(error.localizedDescription)");
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didOccur event: BFEvent, description: String)
    {
        print("Event reported: \(description)");
    }
    
    public func transmitter(_ transmitter: BFTransmitter, shouldConnectSecurelyWithUser user: String) -> Bool {
        return false//if True, it will establish connection with encryption capacities.
        // Not necessary for this case.
    }
    
    public func transmitter(_ transmitter: BFTransmitter, didDetectSecureConnectionWithUser user: String) {
        // A secure connection was detected,
    }
    
    // MARK: -
    
    func processReceived(dict: [String: Any]?) {
        
        guard let dict = dict else {
            return
        }
        
        let receivedID = dict[kIdKey] as! Double
        
        if !self.update(lastId: receivedID) {
            // Command is ignored
            return
        }
        
        let cmd: Comand = Comand(rawValue: dict[kCommandKey] as! Int)!
        
        switch cmd {
        case .image:
            self.showImage(from: dict)
        case .color:
            self.showColor(from: dict)
        case .flashlight:
            self.turnOnFlashlight(flag: true)
        case .text:
            self.showText(from: dict)
        }
        
    }
    
    func showImage(from dictionary: [String: Any]) {
        let imageIndex = dictionary[kImageKey] as! Int
        
        if imageIndex > self.images.count {
            return
        }
        
        self.resetView()
        self.imageView.image = UIImage(named: self.images[imageIndex])
        self.imageView.isHidden = false
    }
    
    func showColor(from dictionary: [String: Any]) {
        let c = dictionary[kColorKey] as! Int
        let receivedColor = UIColor(red: CGFloat((c >> 16) & 0xFF) / 255.0,
                                    green: CGFloat((c >> 8) & 0xFF) / 255.0,
                                    blue: CGFloat(c & 0xFF) / 255.0,
                                    alpha: CGFloat((c >> 24) & 0xFF) / 255.0)
        
        self.resetView()
        self.view.backgroundColor = receivedColor
    }
    
    func turnOnFlashlight(flag: Bool) {
        
        guard let flashlight = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Can't play with torch")
            return
        }
        
        if flashlight.isTorchAvailable && flashlight.hasTorch {
            
            do {
                try flashlight.lockForConfiguration()
            } catch let err as NSError {
                print("ERROR: \(err.localizedDescription)")
                return
            }
            
            if flag {
                
                if flashlight.torchMode == .on {
                    // If flashlight is turned on, the command is ignored
                    return
                } else {
                    flashlight.torchMode = .on
                    self.resetView()
                    self.imageView.image = #imageLiteral(resourceName: "Flashlight")
                    self.imageView.isHidden = false
                    self.perform(#selector(turnOffFlashlight),
                                 with: nil,
                                 afterDelay: 15.0)
                }
                
            } else {
                flashlight.torchMode = .off
                self.resetView()
            }
            
            flashlight.unlockForConfiguration()
        }
    }
    
    @objc func turnOffFlashlight() {
        self.turnOnFlashlight(flag: false)
    }
    
    func showText(from dictionary: [String: Any]) {
        let text = dictionary[kTextKey] as! String
        self.showText(text)
    }
    
    func showText(_ text: String) {
        self.messageLabel.text = text
        self.messageLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        
        self.resetView()
        self.messageLabel.isHidden = false
    }
    
    func resetView() {
        self.imageView.isHidden = true
        self.messageLabel.isHidden = true
        self.view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    func update(lastId receivedId: Double) -> Bool {
        let userDefaults = UserDefaults.standard
        
        let savedId = userDefaults.double(forKey: kLastID)
        
        if receivedId > savedId {
            userDefaults.set(receivedId, forKey: kLastID)
            userDefaults.synchronize()
            return true
        }
        
        return false
    }

}
