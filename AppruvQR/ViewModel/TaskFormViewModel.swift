//
//  TaskFormViewModel.swift
//  AppruvQR
//
//  Created by Jessica Laurentia Tedja on 10/04/26.
//
import Foundation
import SwiftData

enum TaskFormSaveResult {
    case saved
    case pinLimitExceeded
    case reviewerRequired
}

struct TaskFormViewModel {
    static func refreshPinnedCount(modelContext: ModelContext, taskToEdit: TaskModel?) -> Int {
        let descriptor = FetchDescriptor<TaskModel>(
            predicate: #Predicate { task in
                task.isPinned && task.status != "completed"
            }
        )
        
        guard let pinnedTasks = try? modelContext.fetch(descriptor) else {
            return 0
        }
        
        return pinnedTasks.filter { task in
            task.taskId != taskToEdit?.taskId
        }.count
    }
    
    static func combinedDateTime(date: Date?, time: Date?) -> Date? {
        guard let date, let time else { return nil }
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let timeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        dateComponents.second = timeComponents.second
        return Calendar.current.date(from: dateComponents)
    }
    
    static func save(
        modelContext: ModelContext,
        isEditMode: Bool,
        taskToEdit: TaskModel?,
        title: String,
        notes: String,
        taskDate: Date,
        date: Date?,
        time: Date?,
        isPinned: Bool,
        isReportTask: Bool,
        selectedReviewer: ReviewerModel?,
        pinnedCountExcludingCurrentTask: Int
    ) -> TaskFormSaveResult {
        if isPinned && pinnedCountExcludingCurrentTask >= 3 {
            return .pinLimitExceeded
        }
        
        if isReportTask && selectedReviewer == nil {
            return .reviewerRequired
        }
        
        let dueDate = combinedDateTime(date: date, time: time) ?? taskDate
        let computedStatus = dueDate < Date() ? "missed" : "todo"
        
        if isEditMode, let task = taskToEdit {
            task.title = title
            task.notes = notes
            task.dueDate = dueDate
            task.isPinned = isPinned
            if task.status != "completed" {
                task.status = computedStatus
            }
            task.reviewer = isReportTask ? selectedReviewer : nil
        } else {
            let newTask = TaskModel(
                taskId: Int.random(in: 1000...9999),
                title: title,
                notes: notes,
                status: computedStatus,
                dueDate: dueDate,
                isPinned: isPinned
            )
            
            if isReportTask {
                newTask.reviewer = selectedReviewer
            }
            
            modelContext.insert(newTask)
        }
        
        try? modelContext.save()
        return .saved
    }
}
