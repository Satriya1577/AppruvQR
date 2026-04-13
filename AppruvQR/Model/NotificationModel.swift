//
//  NotificationModel.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 07/04/26.
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

    static func addProgressShared(for task: TaskModel, now: Date = Date(), in context: ModelContext) {
        context.insert(
            NotificationModel(
                eventKey: "progress-\(task.taskId)-\(now.timeIntervalSince1970)",
                title: "Progress Shared",
                subtitle: task.title,
                createdAt: now,
                kind: "progressShared"
            )
        )
    }

    static func addReflectionShared(subtitle: String, now: Date = Date(), in context: ModelContext) {
        context.insert(
            NotificationModel(
                eventKey: "reflection-\(Int(now.timeIntervalSince1970))",
                title: "Reflection Shared",
                subtitle: subtitle,
                createdAt: now,
                kind: "reflectionShared"
            )
        )
    }

    @discardableResult
    static func addDailyStreakAcquiredIfNeeded(for user: UserModel, now: Date = Date(), in context: ModelContext) -> Bool {
        guard user.streakCount > 0 else { return false }

        return insertIfNeeded(
            eventKey: "streak-\(dayIdentifier(for: now))",
            title: "Acquired \(user.streakCount) Days Streak!",
            subtitle: "Your streak is active today.",
            kind: "streakAcquired",
            createdAt: now,
            in: context
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

    private static func dayIdentifier(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }

}
