import Foundation
import SwiftData

enum HomeTaskStateService {
    static func generateDueSoonNotifications(for tasks: [TaskModel], in modelContext: ModelContext) -> Bool {
        let now = Date()
        var insertedAnyNotification = false

        for task in tasks {
            let inserted = NotificationCenterStore.addTaskDueSoonIfNeeded(for: task, now: now, in: modelContext)
            insertedAnyNotification = insertedAnyNotification || inserted
        }

        return insertedAnyNotification
    }

    static func checkAndUpdateMissedTasks(for tasks: [TaskModel], user: UserModel?) -> Bool {
        let now = Date()
        var hasUpdates = false

        for task in tasks where task.status == "todo" && now > task.dueDate {
            task.status = "missed"
            hasUpdates = true
        }

        user?.applyMissedDayPenaltyIfNeeded(referenceDate: now)

        return hasUpdates
    }
}
