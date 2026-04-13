import Foundation
import SwiftData

enum HomeTaskStateService {
    static func generateDueTodayNotifications(for tasks: [TaskModel], in modelContext: ModelContext) -> Bool {
        let now = Date()
        var insertedAnyNotification = false

        for task in tasks {
            let inserted = NotificationCenterStore.addTaskDueTodayIfNeeded(for: task, now: now, in: modelContext)
            insertedAnyNotification = insertedAnyNotification || inserted
        }

        return insertedAnyNotification
    }

    static func checkAndUpdateMissedTasks(for tasks: [TaskModel]) -> Bool {
        let now = Date()
        var hasUpdates = false

        for task in tasks where task.status == "todo" && now > task.dueDate {
            task.status = "missed"
            hasUpdates = true
        }

        return hasUpdates
    }
}
