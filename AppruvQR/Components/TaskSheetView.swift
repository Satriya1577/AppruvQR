//
//  TaskSheetView.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 06/04/26.
//

import SwiftUI
import SwiftData

struct TaskSheetView: View {
    private enum Field {
        case title
        case notes
    }
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    
    var isEditMode: Bool = false
    var taskToEdit: TaskModel?
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var notes = ""
    @State private var taskDate = Date()
    @State private var date: Date? = nil
    @State private var time: Date? = nil
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var isReportTask = false
    @State private var isPinned = false
    @State private var showPinLimitAlert = false
    @State private var showReviewerRequiredAlert = false
    @State private var pinnedTodoCountExcludingCurrentTask = 0
    @State private var selectedReviewer: ReviewerModel? = nil
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
                header
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        taskInputSection
                        reportAndPinSection
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
            refreshPinnedTodoCountExcludingCurrentTask()
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
    
    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Create Task")
                .font(.headline)
            
            Spacer()
            
            Button {
                focusedField = nil
                refreshPinnedTodoCountExcludingCurrentTask()
                
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
            } label: {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .clipShape(Circle())
            }
            .disabled(!isFormValid)
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
    private var taskInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading) {
                TextField("Title", text: $title)
                    .focused($focusedField, equals: .title)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
                    .padding(.bottom, 8)
                Divider()
                TextField("Notes", text: $notes)
                    .focused($focusedField, equals: .notes)
                    .submitLabel(.done)
                    .onSubmit {
                        focusedField = nil
                    }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(16)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Date & Time")
                    .padding(.top, 6)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        focusedField = nil
                        if date == nil {
                            date = Date()
                        }
                        showDatePicker.toggle()
                        showTimePicker = false
                    } label: {
                        HStack {
                            Image(systemName: "calendar")
                            
                            VStack(alignment: .leading) {
                                Text("Date")
                                
                                if let date {
                                    Text(date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                } else {
                                    Text("This field is required")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    
                    if showDatePicker {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { date ?? Date() },
                                set: { date = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                    }
                    
                    Divider()
                    
                    Button {
                        focusedField = nil
                        if time == nil {
                            time = Date()
                        }
                        showTimePicker.toggle()
                        showDatePicker = false
                    } label: {
                        HStack {
                            Image(systemName: "clock")
                            
                            VStack(alignment: .leading) {
                                Text("Time")
                                
                                if let time {
                                    Text(time, style: .time)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                } else {
                                    Text("This field is required")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                    
                    if showTimePicker {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { time ?? Date() },
                                set: { time = $0 }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                        .clipped()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(16)
            }
        }
    }
    
    private var reportAndPinSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(spacing: 0) {
                Toggle(isOn: $isReportTask) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.fill")
                            .foregroundColor(.black)
                        Text("Report Task")
                    }
                }
                .padding()
                
                if isReportTask {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Report Task To:")
                            .font(.caption)
                            .foregroundColor(.red)
                        
                        Button(action: { showReviewerList = true }) {
                            HStack(spacing: 12) {
                                if let reviewer = selectedReviewer {
                                    ZStack {
                                        Circle().fill(Color.purple).frame(width: 28, height: 28)
                                        Text(String(reviewer.name.prefix(2)).uppercased()).font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(reviewer.name).font(.system(size: 16, weight: .semibold)).foregroundColor(.primary)
                                        Text(reviewer.user_id).font(.system(size: 12)).foregroundColor(.gray)
                                    }
                                } else {
                                    Image(systemName: "person.badge.plus").font(.system(size: 14, weight: .semibold)).foregroundColor(.black)
                                    Text("Select Reviewer")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                
                                Spacer()
                                if !isEditMode {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Divider()
                        
                        Button(action: { showScanner = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "qrcode.viewfinder")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                                Text("Scan QR to Add New")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .padding(.leading, 28)
                }
                
                Divider().padding(.horizontal)
                
                Toggle(isOn: $isPinned) {
                    HStack(spacing: 12) {
                        Label("Pin", systemImage: "pin")
                    }
                }
                .padding()
                
                if pinLimitExceeded {
                    Text("Maximum 3 pinned tasks. Unpin one task first.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
        }
    }
    
    private var pinLimitExceeded: Bool {
        isPinned && pinnedTodoCountExcludingCurrentTask >= 3
    }
    
    private func setupInitialData() {
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
        refreshPinnedTodoCountExcludingCurrentTask()
    }
    
    private func refreshPinnedTodoCountExcludingCurrentTask() {
        pinnedTodoCountExcludingCurrentTask = TaskFormViewModel.refreshPinnedCount(
            modelContext: modelContext,
            taskToEdit: taskToEdit
        )
    }
    
}

#Preview {
    TaskSheetView()
}
