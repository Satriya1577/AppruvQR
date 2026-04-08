//
//  NotificationModel.swift
//  AppruvQR
//

import Foundation
import SwiftData

@Model
final class NotificationModel {
    @Attribute(.unique) var eventKey: String
    var title: String
    var subtitle: String
    var createdAt: Date
    var kind: String

    init(eventKey: String, title: String, subtitle: String, createdAt: Date, kind: String) {
        self.eventKey = eventKey
        self.title = title
        self.subtitle = subtitle
        self.createdAt = createdAt
        self.kind = kind
    }
}

enum NotificationCenterStore {
    static func addTaskDueTodayIfNeeded(for task: TaskModel, now: Date = Date(), in context: ModelContext) -> Bool {
        guard task.status == "todo" else { return false }
        guard Calendar.current.isDateInToday(task.dueDate) else { return false }

        let triggerDate = task.dueDate.addingTimeInterval(-4 * 60 * 60)
        guard now >= triggerDate, now <= task.dueDate else { return false }

        let eventKey = "due-\(task.taskId)-\(Int(task.dueDate.timeIntervalSince1970))"
        return insertIfNeeded(
            eventKey: eventKey,
            title: "Task Due Today! Start Now.",
            subtitle: task.title,
            kind: "dueToday",
            createdAt: now,
            in: context
        )
    }

    static func addTaskCompleted(for task: TaskModel, now: Date = Date(), in context: ModelContext) {
        context.insert(
            NotificationModel(
                eventKey: "completed-\(task.taskId)-\(now.timeIntervalSince1970)",
                title: "Task Completed",
                subtitle: task.title,
                createdAt: now,
                kind: "taskCompleted"
            )
        )
    }

    @discardableResult
    private static func insertIfNeeded(
        eventKey: String,
        title: String,
        subtitle: String,
        kind: String,
        createdAt: Date,
        in context: ModelContext
    ) -> Bool {
        let descriptor = FetchDescriptor<NotificationModel>(
            predicate: #Predicate { notification in
                notification.eventKey == eventKey
            }
        )

        if let existing = try? context.fetch(descriptor), !existing.isEmpty {
            return false
        }

        context.insert(
            NotificationModel(
                eventKey: eventKey,
                title: title,
                subtitle: subtitle,
                createdAt: createdAt,
                kind: kind
            )
        )
        return true
    }

}
