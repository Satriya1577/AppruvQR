//
//  HomeView.swift
//  AppruvQR
//

import SwiftUI
import SwiftData

// MARK: - 2. HomeView
struct HomeView: View {
    // Akses Database SwiftData
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskModel.dueDate) private var allTasks: [TaskModel]
    @Query private var profiles: [UserModel]
    
    @State private var selectedFilter: FilterTab = .primary
    @State private var showCreateTask = false
    @State private var showStreakLostAlert = false
    @State private var showReflectionSheet = false
    
    let appBackground = Color("AppBackground")

    // Helper: Angka badge missed tasks
    var missedTaskCount: Int {
        allTasks.filter { $0.status == "missed" }.count
    }
    
    // Mengambil profil pertama (satu-satunya user)
    var currentUser: UserModel? {
        profiles.first
    }
    
    var filteredTasks: [TaskModel] {
        HomeTaskPresentation.filteredTasks(from: allTasks, selectedFilter: selectedFilter)
    }
    
    var groupedTasks: [(String, [TaskModel])] {
        HomeTaskPresentation.groupedTasks(from: filteredTasks, selectedFilter: selectedFilter)
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                appBackground.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HomeHeaderView(
                        appBackground: appBackground,
                        streakCount: currentUser?.streakCount ?? 0,
                        selectedFilter: $selectedFilter,
                        missedTaskCount: missedTaskCount
                    )

                    HomeTaskListView(
                        selectedFilter: selectedFilter,
                        filteredTasks: filteredTasks,
                        groupedTasks: groupedTasks,
                        formatDateHeader: formatDateHeader,
                        onComplete: completeTask,
                        onStreakUpdated: {
                            handleQualifiedStreakActivity()
                            evaluateStreakLostState()
                        },
                        onProgressShared: handleProgressShared
                    )
                }
                
                // --- FLOATING ACTION BUTTON ---
                Button(action: { showCreateTask = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .medium)).foregroundColor(.white)
                        .frame(width: 60, height: 60).background(Color.blue)
                        .clipShape(Circle()).shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showCreateTask) {
                TaskSheetView()
            }
            .sheet(isPresented: $showReflectionSheet, onDismiss: {
                evaluateStreakLostState()
            }) {
                ReflectionView(onSharedSuccess: {
                    handleReflectionSharedSuccess()
                })
            }
            .alert("Streak Lost", isPresented: $showStreakLostAlert) {
                Button("No", role: .destructive) {
                    handleDeclineStreakRecovery()
                }
                Button("Yes") {
                    showReflectionSheet = true
                }
            } message: {
                Text("You Missed a day. Writed a quick reflection to continue your streak")
            }
            .onAppear {
                seedMockDataIfNeeded()
                refreshTaskState()
            }
        }
    }
    
    private func seedMockDataIfNeeded() {
        HomeMockDataSeeder.seedIfNeeded(allTasks: allTasks, in: modelContext)
    }
    
    // Sync task-driven notifications and overdue state when the home screen becomes active.
    private func refreshTaskState() {
        let hasNotificationUpdates = HomeTaskStateService.generateDueTodayNotifications(
            for: allTasks,
            in: modelContext
        )
        let hasMissedUpdates = HomeTaskStateService.checkAndUpdateMissedTasks(for: allTasks)

        if hasNotificationUpdates || hasMissedUpdates {
            try? modelContext.save()
        }
    }
    
    private func completeTask(task: TaskModel) {
        withAnimation(.spring()) {
            guard task.status != "completed" else { return }
            task.status = "completed"
            NotificationCenterStore.addTaskCompleted(for: task, in: modelContext)
            try? modelContext.save()
        }
    }

    private func handleQualifiedStreakActivity() {
        guard let user = currentUser else { return }
        _ = NotificationCenterStore.addDailyStreakAcquiredIfNeeded(for: user, in: modelContext)
    }

    private func handleProgressShared(task: TaskModel) {
        NotificationCenterStore.addProgressShared(for: task, in: modelContext)

        if let user = currentUser {
            let previousStreakCount = user.streakCount
            let previousLastUpdated = user.streakLastUpdated
            user.updateStreak()
            if user.streakCount != previousStreakCount || user.streakLastUpdated != previousLastUpdated {
                _ = NotificationCenterStore.addDailyStreakAcquiredIfNeeded(for: user, in: modelContext)
            }
        }

        try? modelContext.save()
        evaluateStreakLostState()
    }
    
    private func evaluateStreakLostState() {
        guard let user = currentUser else { return }
        showStreakLostAlert = user.isStreakLost && !showReflectionSheet
    }
    
    private func handleDeclineStreakRecovery() {
        guard let user = currentUser else { return }
        user.resetLostStreak()
        try? modelContext.save()
        selectedFilter = .primary
    }
    
    private func handleReflectionSharedSuccess() {
        guard let user = currentUser else { return }
        user.recoverLostStreakAfterReflection()
        NotificationCenterStore.addReflectionShared(
            subtitle: "Your streak reflection has been shared.",
            in: modelContext
        )
        try? modelContext.save()
    }
    
    private func formatDateHeader(_ dateString: String) -> String {
        HomeTaskPresentation.dateHeader(for: dateString, selectedFilter: selectedFilter)
    }
}

#Preview {
    HomeView()
}
