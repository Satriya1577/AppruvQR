//
//  ReviewerModel.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 07/04/26.
//

import Foundation
import SwiftData

@Model
class ReviewerModel {
    var user_id: String
    var name: String
    var timestamp: Int
    var signature: String
    
    init(user_id: String, name: String, timestamp: Int, signature: String) {
        self.user_id = user_id
        self.name = name
        self.timestamp = timestamp
        self.signature = signature
    }
    
}
