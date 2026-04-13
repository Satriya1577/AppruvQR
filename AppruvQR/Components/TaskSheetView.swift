//
//  TaskSheetView.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 06/04/26.
//

import SwiftUI
import SwiftData

struct TaskSheetView: View {
    enum Field {
        case title
        case notes
    }
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) var modelContext
    var isEditMode: Bool = false
    var taskToEdit: TaskModel?
    @Environment(\.dismiss) var dismiss
    @State var title = ""
    @State var notes = ""
    @State var taskDate = Date()
    @State var date: Date? = nil
    @State var time: Date? = nil
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State var isReportTask = false
    @State var isPinned = false
    @State private var showPinLimitAlert = false
    @State private var showReviewerRequiredAlert = false
    @State var pinnedTodoCountExcludingCurrentTask = 0
    @State var selectedReviewer: ReviewerModel? = nil
    @State private var showReviewerList = false
    @State private var showScanner = false
    @FocusState private var focusedField: Field?
    
    private var isFormValid: Bool {
        !title.isEmpty && date != nil && time != nil
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.91, green: 0.94, blue: 0.98)
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                }
            
            VStack(spacing: 20) {
                HeaderTaskSheetView(
                    title: "Create Task",
                    isSaveEnabled: isFormValid,
                    onClose: {
                        dismiss()
                    },
                    onSave: {
                        focusedField = nil
                        pinnedTodoCountExcludingCurrentTask = TaskFormViewModel.refreshPinnedCount(
                            modelContext: modelContext,
                            taskToEdit: taskToEdit
                        )
                        
                        let result = TaskFormViewModel.save(
                            modelContext: modelContext,
                            isEditMode: isEditMode,
                            taskToEdit: taskToEdit,
                            title: title,
                            notes: notes,
                            taskDate: taskDate,
                            date: date,
                            time: time,
                            isPinned: isPinned,
                            isReportTask: isReportTask,
                            selectedReviewer: selectedReviewer,
                            pinnedCountExcludingCurrentTask: pinnedTodoCountExcludingCurrentTask
                        )
                        
                        switch result {
                        case .saved:
                            presentationMode.wrappedValue.dismiss()
                        case .pinLimitExceeded:
                            showPinLimitAlert = true
                        case .reviewerRequired:
                            showReviewerRequiredAlert = true
                        }
                    }
                )
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        TaskInputSectionView(
                            title: $title,
                            notes: $notes,
                            date: $date,
                            time: $time,
                            showDatePicker: $showDatePicker,
                            showTimePicker: $showTimePicker,
                            focusedField: $focusedField
                        )
                        TaskReportAndPinSectionView(
                            isReportTask: $isReportTask,
                            isPinned: $isPinned,
                            selectedReviewer: $selectedReviewer,
                            showReviewerList: $showReviewerList,
                            showScanner: $showScanner,
                            isEditMode: isEditMode,
                            pinLimitExceeded: pinLimitExceeded
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
<<<<<<< Updated upstream
                .scrollDismissesKeyboard(.immediately)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 4).onChanged { _ in
                        focusedField = nil
                    }
                )
=======
                .scrollDismissesKeyboard(.interactively)
>>>>>>> Stashed changes
            }
        }
        .onAppear(perform: setupInitialData)
        .onChange(of: isPinned) { _, newValue in
            focusedField = nil
            pinnedTodoCountExcludingCurrentTask = TaskFormViewModel.refreshPinnedCount(
                modelContext: modelContext,
                taskToEdit: taskToEdit
            )
            if newValue && pinLimitExceeded {
                showPinLimitAlert = true
            }
        }
        .onChange(of: isReportTask) { _, newValue in
            focusedField = nil
            if !newValue {
                selectedReviewer = nil
            }
        }
        .sheet(isPresented: $showScanner) {
            TaskReviewerScannerSheet(
                isPresented: $showScanner,
                selectedReviewer: $selectedReviewer
            )
        }
        .sheet(isPresented: $showReviewerList) {
            ReviewerSelectionSheetView(onSelect: { reviewer in
                self.selectedReviewer = reviewer
            })
        }
        .alert("Pin Limit", isPresented: $showPinLimitAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Maximum 3 pinned tasks. Unpin one task first.")
        }
        .alert("Reviewer Required", isPresented: $showReviewerRequiredAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please select a reviewer before saving this report task.")
        }
    }
    
}

#Preview {
    TaskSheetView()
}
