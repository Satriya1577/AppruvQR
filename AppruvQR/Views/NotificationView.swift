//
//  NotificationView.swift
//  AppruvQR
//
//  Created by Ruth Julien Sutanto on 06/04/26.
//

import SwiftUI
import SwiftData

struct NotificationView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NotificationModel.createdAt, order: .reverse) private var notifications: [NotificationModel]

    @State private var showingClearAllAlert = false
    private let pageBackground = Color(.background)

    var body: some View {
        ZStack {
            pageBackground
                .ignoresSafeArea()

            List {
                Section {
                    if notifications.isEmpty {
                        ContentUnavailableView(
                            "No Notifications Yet",
                            systemImage: "bell.slash",
                            description: Text("Task reminders and activity updates will appear heeere.")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(notifications) { notification in
                            NotificationCardView(notification: notification)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Delete", role: .destructive) {
                                    modelContext.delete(notification)
                                    try? modelContext.save()
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !notifications.isEmpty {
                    Button("Clear All") {
                        showingClearAllAlert = true
                    }
                    .tint(.red)
                }
            }
        }
        .alert("Delete", isPresented: $showingClearAllAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                for notification in notifications {
                    modelContext.delete(notification)
                }
                try? modelContext.save()
            }
        } message: {
            Text("Are you sure want to clear all of the list?")
        }
    }
}

#Preview {
    do {
        // 1. Buat konfigurasi database sementara khusus untuk Preview
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: NotificationModel.self, configurations: config)
        
        // 2. Buat beberapa data dummy
        let dummyWarning = NotificationModel(
            eventKey: "dummy_due_01",
            title: "Task Due Today! Start Now.",
            subtitle: "Menyelesaikan UI Design Aplikasi AppruvQR",
            createdAt: Date(),
            kind: "dueToday"
        )
        
        let dummySuccess = NotificationModel(
            eventKey: "dummy_completed_02",
            title: "Task Completed",
            subtitle: "Riset Kompetitor Aplikasi",
            createdAt: Date().addingTimeInterval(-3600), // 1 jam yang lalu
            kind: "taskCompleted"
        )
        
        // 3. Masukkan data tersebut ke dalam database sementara
        container.mainContext.insert(dummyWarning)
        container.mainContext.insert(dummySuccess)
        
        // 4. Tampilkan View dengan container yang sudah berisi data
        return NavigationStack {
            NotificationView()
        }
        .modelContainer(container) // Hubungkan container ke View
        
    } catch {
        return Text("Gagal memuat preview: \(error.localizedDescription)")
    }
}
