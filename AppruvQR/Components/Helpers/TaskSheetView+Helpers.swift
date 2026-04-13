//
//  TaskSheetView+Helpers.swift
//  AppruvQR
//
//  Created by Jessica Laurentia Tedja on 13/04/26.
//

import SwiftUI

extension TaskSheetView {
    var pinLimitExceeded: Bool {
        isPinned && pinnedTodoCountExcludingCurrentTask >= 3
    }

    func setupInitialData() {
        if isEditMode, let task = taskToEdit {
            title = task.title
            notes = task.notes
            taskDate = task.dueDate
            date = task.dueDate
            time = task.dueDate
            isPinned = task.isPinned
            selectedReviewer = task.reviewer
            isReportTask = task.reviewer != nil
        }
        pinnedTodoCountExcludingCurrentTask = TaskFormViewModel.refreshPinnedCount(
            modelContext: modelContext,
            taskToEdit: taskToEdit
        )
    }
}
