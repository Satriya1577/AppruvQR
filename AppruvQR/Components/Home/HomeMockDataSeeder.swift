import Foundation
import SwiftData

enum HomeMockDataSeeder {
    static func seedIfNeeded(allTasks: [TaskModel], in modelContext: ModelContext) {
        let now = Date()
        let calendar = Calendar.current
        var existingTaskIds = Set(allTasks.map(\.taskId))

        let todayAt9 = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now
        let todayAt14 = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now) ?? now
        let todayAt17 = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: now) ?? now
        let todayAt21 = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: now) ?? now
        let todayAt12 = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now) ?? now
        let tomorrowAt10 = calendar.date(byAdding: .day, value: 1, to: todayAt9) ?? now.addingTimeInterval(86_400)
        let yesterdayAt16 = calendar.date(byAdding: .day, value: -1, to: todayAt14) ?? now.addingTimeInterval(-86_400)

        let samples: [TaskModel] = [
            TaskModel(taskId: 90_001, title: "Review PR #12", notes: "Check comments and run tests", status: "todo", dueDate: todayAt14, isPinned: true),
            TaskModel(taskId: 90_002, title: "Prepare stand-up notes", notes: "Summarize yesterday & plan today", status: "todo", dueDate: todayAt9, isPinned: true),
            TaskModel(taskId: 90_003, title: "Write unit tests", notes: "Cover edge cases for login flow", status: "todo", dueDate: todayAt17, isPinned: false),
            TaskModel(taskId: 90_004, title: "Book flight ticket to CGK", notes: "using agoda or booking.com", status: "todo", dueDate: todayAt21, isPinned: false),
            TaskModel(taskId: 90_005, title: "Merge PR #082838", notes: "do not forget to do this one", status: "todo", dueDate: todayAt12, isPinned: false),
            TaskModel(taskId: 90_006, title: "Plan sprint backlog", notes: "Draft list of priorities", status: "todo", dueDate: tomorrowAt10, isPinned: false),
            TaskModel(taskId: 90_010, title: "Wireframing #2", notes: "testing only", status: "todo", dueDate: tomorrowAt10, isPinned: false),
            TaskModel(taskId: 90_011, title: "Gathering data from user", notes: "Unique note text", status: "todo", dueDate: tomorrowAt10, isPinned: false),
            TaskModel(taskId: 90_012, title: "Testing new feature #4", notes: "Unique feature", status: "todo", dueDate: tomorrowAt10, isPinned: false),
            TaskModel(taskId: 90_007, title: "Email project update", notes: "Send to stakeholders", status: "completed", dueDate: yesterdayAt16, isPinned: false),
            TaskModel(taskId: 90_008, title: "Refactor login flow", notes: "Split into smaller components", status: "todo", dueDate: now.addingTimeInterval(-3_600), isPinned: false),
            TaskModel(taskId: 90_009, title: "Update streak feature", notes: "Streak bam, bam, bam!", status: "todo", dueDate: now.addingTimeInterval(-3_600), isPinned: false)
        ]

        let sampleSignatures = Set(samples.map { "\($0.title)|\($0.notes)" })
        var seenSignatures = Set<String>()
        var removedDuplicates = 0

        for task in allTasks {
            let signature = "\(task.title)|\(task.notes)"
            guard sampleSignatures.contains(signature) else { continue }

            if seenSignatures.contains(signature) {
                modelContext.delete(task)
                existingTaskIds.remove(task.taskId)
                removedDuplicates += 1
            } else {
                seenSignatures.insert(signature)
            }
        }

        var insertedCount = 0
        for task in samples {
            let signature = "\(task.title)|\(task.notes)"
            guard !existingTaskIds.contains(task.taskId), !seenSignatures.contains(signature) else { continue }
            modelContext.insert(task)
            existingTaskIds.insert(task.taskId)
            seenSignatures.insert(signature)
            insertedCount += 1
        }

        if insertedCount > 0 || removedDuplicates > 0 {
            try? modelContext.save()
            print("Mock sync done. inserted=\(insertedCount), removedDuplicates=\(removedDuplicates)")
        }
    }
}
