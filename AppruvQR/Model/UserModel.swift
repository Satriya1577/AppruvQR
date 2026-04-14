//
//  UserModel.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 07/04/26.
//

import Foundation
import SwiftData

@Model
class UserModel {
    var user_id: String
    var name: String
    var timestamp: Int
    var signature: String
    
    // Minimal 0
    var streakCount: Int = 0 {
        didSet {
            if streakCount < 0 {
                streakCount = 0
            }
        }
    }
    
    var streakHealthCount: Int = 3 {
        didSet {
            if streakHealthCount > 3 {
                streakHealthCount = 3
            } else if streakHealthCount < 0 {
                streakHealthCount = 0
            }
        }
    }
    
    var streakLastUpdated: Date?
    var isStreakLost: Bool = false
    var pendingRecoveryStreakCount: Int?
    var streakLastHealthPenaltyDate: Date?
    
    init(user_id: String, name: String, timestamp: Int, signature: String) {
        self.user_id = user_id
        self.name = name
        self.timestamp = timestamp
        self.signature = signature
    }
    
}
