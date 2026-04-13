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
                            description: Text("Task reminders and activity updates will appear here.")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(notifications) { notification in
                            NotificationCardView(notification: notification)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button("Delete", role: .destructive) {
                                    NotificationViewModel.delete(notification, from: modelContext)
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
                NotificationViewModel.clearAll(notifications, from: modelContext)
            }
        } message: {
            Text("Are you sure want to clear all of the list?")
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: NotificationModel.self, configurations: config)

        for notification in NotificationModel.previewSamples {
            container.mainContext.insert(notification)
        }

        return NavigationStack {
            NotificationView()
        }
        .modelContainer(container)
    } catch {
        return Text("Gagal memuat preview: \(error.localizedDescription)")
    }
}
