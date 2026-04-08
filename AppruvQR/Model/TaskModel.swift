//
//  TasModel.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 07/04/26.
//

import Foundation
import SwiftData

@Model
class TaskModel {
    @Attribute(.unique) var taskId: Int
    var title: String
    var notes: String
    var status: String // "todo" atau "completed"
    var dueDate: Date
    var isPinned: Bool
    
    // Hubungan ke Reviewer (Relasi One-to-One)
    var reviewer: ReviewerModel?
    
    init(taskId: Int, title: String, notes: String, status: String, dueDate: Date, isPinned: Bool, reviewer: ReviewerModel? = nil) {
        self.taskId = taskId
        self.title = title
        self.notes = notes
        self.status = status
        self.dueDate = dueDate
        self.isPinned = isPinned
        self.reviewer = reviewer
    }
    
    // Properti bantuan untuk mengecek Missed secara real-time
    var isMissed: Bool {
        return Date() > dueDate && status != "completed"
    }
}
