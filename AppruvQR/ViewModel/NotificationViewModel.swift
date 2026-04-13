//
//  NotificationViewModel.swift
//  AppruvQR
//

import Foundation
import SwiftData

struct NotificationViewModel {
    static func delete(_ notification: NotificationModel, from modelContext: ModelContext) {
        modelContext.delete(notification)
        try? modelContext.save()
    }

    static func clearAll(_ notifications: [NotificationModel], from modelContext: ModelContext) {
        for notification in notifications {
            modelContext.delete(notification)
        }
        try? modelContext.save()
    }
}
