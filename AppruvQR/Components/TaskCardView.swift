//
//  TaskCardView.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 06/04/26.
//

import SwiftUI
import SwiftData
import UIKit

struct SwipeableTaskRow: View {
    var task: TaskModel
    var onComplete: () -> Void
    var onStreakUpdated: () -> Void = {}
    var onProgressShared: (TaskModel) -> Void = { _ in }
    
    @Environment(\.modelContext) private var modelContext
    @State private var showEditSheet = false
    @State private var showShareSheet = false
    
    @Query private var allTasks: [TaskModel]
    @Query private var profiles: [UserModel]
    @State private var showPinLimitAlert = false

    private var pinnedTodoCount: Int {
        allTasks.filter { $0.isPinned }.count
    }
    
    var body: some View {
        TaskCardView(task: task, onComplete: onComplete, onStreakUpdated: onStreakUpdated) {
            showEditSheet = true
        }
            // --- SWIPE DARI KANAN (Delete & Share) ---
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                // Tombol Delete (Otomatis warna merah karena role: .destructive)
                Button(role: .destructive) {
                    withAnimation {
                        modelContext.delete(task)
                        try? modelContext.save()
                    }
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
                
                // Tombol Share
                Button {
                    showShareSheet = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .tint(.blue) // Ubah warna background tombol jadi biru
            }
            // --- SWIPE DARI KIRI (Pin) ---
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    withAnimation {
                        if task.isPinned {
                            task.isPinned = false
                        } else if pinnedTodoCount < 3 {
                            task.isPinned = true
                        } else {
                            showPinLimitAlert = true
                        }
                    }
                } label: {
                    Label(task.isPinned ? "Unpin" : "Pin", systemImage: task.isPinned ? "pin.slash.fill" : "pin.fill")
                }
                .tint(.green)
            }
            .alert("Pin Limit Reached", isPresented: $showPinLimitAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You can pin up to 3 tasks. Unpin one of them first.")
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityShareSheet(items: [shareText]) { completed in
                    guard completed else { return }
                    handleShareCompleted()
                }
            }
            .sheet(isPresented: $showEditSheet) {
                TaskSheetView(isEditMode: true, taskToEdit: task)
            }
            .sheet(isPresented: $showShareSheet) {
                ActivityShareSheet(
                    items: ["\(task.title)\nDeadline: \(task.dueDate.formatted())\nStatus: \(task.status)"],
                    onComplete: { completed in
                        if completed {
                            onProgressShared(task)
                        }
                    }
                )
            }
    }

    private var shareText: String {
        "\(task.title)\nDeadline: \(task.dueDate.formatted())\nStatus: \(task.status)"
    }

    private func handleShareCompleted() {
        guard let currentUser = profiles.first else { return }
        currentUser.updateStreak()
        onStreakUpdated()
        try? modelContext.save()
    }
}

struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    var onComplete: (Bool) -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, _ in
            onComplete(completed)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


struct TaskCardView: View {
    var task: TaskModel
    var onComplete: () -> Void
    var onStreakUpdated: () -> Void
    var onInfoTap: () -> Void = {}
    
    @Environment(\.modelContext) private var modelContext
    @State private var showScanner = false
    @State private var scanMessage: String? = nil
    @State private var scanSuccess = false
    @State private var editableTitle = ""
    @State private var isEditingTitle = false
    @FocusState private var isTitleFieldFocused: Bool
    @Query private var profiles: [UserModel]
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Indikator Status / Tombol Selesai/Centang
            Button(action: {
                if task.status == "completed" { return }
                if task.reviewer != nil {
                    scanMessage = nil
                    scanSuccess = false
                    showScanner = true
                } else {
                    if let currentUser = profiles.first {
                        let previousStreakCount = currentUser.streakCount
                        let previousLastUpdated = currentUser.streakLastUpdated
                        currentUser.updateStreak()
                        if currentUser.streakCount != previousStreakCount || currentUser.streakLastUpdated != previousLastUpdated {
                            onStreakUpdated()
                        }
                    }
                    onComplete()
                }
            }) {
                ZStack {
                    Circle()
                        .strokeBorder(statusColor, lineWidth: task.status == "completed" ? 0 : 2)
                        .background(Circle().fill(task.status == "completed" ? Color.blue : Color.clear))
                        .frame(width: 20, height: 20)
                    
                    if task.status == "completed" {
                        Image(systemName: "checkmark").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    } else if task.isMissed {
                        Image(systemName: "exclamationmark").font(.system(size: 14, weight: .bold)).foregroundColor(.red)
                    } else if task.reviewer != nil {
                        Image(systemName: "lock.fill").font(.system(size: 12)).foregroundColor(.gray)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle()) 
            
            VStack(alignment: .leading, spacing: 4) {
                if isEditingTitle {
                    TextField("Task title", text: $editableTitle)
                        .font(.system(size: 18, weight: .semibold))
                        .textFieldStyle(.plain)
                        .focused($isTitleFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            commitTitleEdit()
                        }
                        .onChange(of: isTitleFieldFocused) { _, isFocused in
                            if !isFocused {
                                commitTitleEdit()
                            }
                        }
                } else {
                    Text(task.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .onTapGesture {
                            beginTitleEdit()
                        }
                }
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill").font(.system(size: 12))
                    Text(formatTime(task.dueDate)).font(.system(size: 13))
                }
                .foregroundColor(task.isMissed ? .red : .gray)
            }
            
            Spacer()
            
            // Badge Reviewer
            if !isEditingTitle, let reviewer = task.reviewer {
                let initials = String(reviewer.name.prefix(2)).uppercased()
                ZStack {
                    Circle().fill(badgeColor(initials)).frame(width: 36, height: 36)
                    Text(initials)
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(.white)
                }
                .overlay(alignment: .bottomTrailing) {
                    if task.status == "completed" {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.blue)
                            .background(Circle().fill(Color.white).frame(width: 14, height: 14)).offset(x: 4, y: 4)
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 18).fill(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(task.isMissed ? Color.red.opacity(0.3) : Color.clear, lineWidth: 1))
        )
        .overlay(alignment: .topTrailing) {
            if isEditingTitle {
                Button {
                    commitTitleEdit()
                    onInfoTap()
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .padding(.top, 6)
                .padding(.trailing, 8)
            }
        }
        .sheet(isPresented: $showScanner) {
            scannerSheet
        }
        .onAppear {
            editableTitle = task.title
        }
        .onChange(of: task.title) { _, newTitle in
            if !isEditingTitle {
                editableTitle = newTitle
            }
        }
    }
    
    private var statusColor: Color {
        if task.status == "completed" { return .blue }
        return task.isMissed ? .red : .gray.opacity(0.4)
    }
    
    private var scannerSheet: some View {
        VStack(spacing: 16) {
            Text("Scan Reviewer QR").font(.headline).padding(.top, 24)
            if let msg = scanMessage {
                Text(msg).font(.subheadline).bold().foregroundColor(scanSuccess ? .green : .red).multilineTextAlignment(.center).padding(.horizontal)
            }
            QRCameraScanner { code in
                let result = ScannerValidator.processScan(jsonString: code, requiredReviewerID: task.reviewer?.user_id ?? "")
                scanMessage = result.message
                scanSuccess = result.success
                if result.success {
                    if let currentUser = profiles.first {
                        let previousStreakCount = currentUser.streakCount
                        let previousLastUpdated = currentUser.streakLastUpdated
                        currentUser.updateStreak()
                        if currentUser.streakCount != previousStreakCount || currentUser.streakLastUpdated != previousLastUpdated {
                            onStreakUpdated()
                        }
                    }
                    onComplete()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { showScanner = false }
                }
            }
            .frame(width: 250, height: 250).cornerRadius(16).padding()
            Button("Cancel") { showScanner = false }.foregroundColor(.red)
            Spacer()
        }
        .presentationDetents([.medium])
    }
    
    private func beginTitleEdit() {
        editableTitle = task.title
        isEditingTitle = true
        isTitleFieldFocused = true
    }
    
    private func commitTitleEdit() {
        let trimmedTitle = editableTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            editableTitle = task.title
            isEditingTitle = false
            return
        }
        
        if trimmedTitle != task.title {
            task.title = trimmedTitle
            try? modelContext.save()
        }
        
        editableTitle = task.title
        isEditingTitle = false
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: date)
    }

    private func badgeColor(_ initials: String) -> Color {
        let colors: [Color] = [.orange, .teal, .indigo, .pink, .purple]
        let index = abs(initials.hashValue) % colors.count
        return colors[index]
    }
}

