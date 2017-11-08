//
//  Player.swift
//  TicTacToe
//
//  Created by Bridgefy on 5/23/17.
//  Copyright © 2017 Bridgefy. All rights reserved.
//

import UIKit

enum PlayerStatus: Int {
    case NoAvailable = -1
    case Available = 1
    case Occupied = 0
    
    var text: String {
        switch self {
        case .NoAvailable:
            return "No available"
        case .Available:
            return "Available"
        case .Occupied:
            return "Already playing"
        }
    }
}

class Player: NSObject {
    let identifier: String
    var playerStatus: PlayerStatus
    var userName: String = ""
    var connectionNotified: Bool
    
    init(_ identifier: String) {
        self.identifier = identifier
        self.playerStatus = .NoAvailable
        self.connectionNotified = false
    }
}
