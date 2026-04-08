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
                            let iconName = notification.kind == "dueToday" ? "clock.badge.exclamationmark" : "checkmark.circle.fill"
                            let iconColor: Color = notification.kind == "dueToday" ? .orange : .green

                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: iconName)
                                    .font(.title3)
                                    .foregroundStyle(iconColor)
                                    .frame(width: 28)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(notification.title)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text(notification.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer(minLength: 12)

                                Text(notification.createdAt.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                            .contentShape(Rectangle())
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
    NavigationStack {
        NotificationView()
    }
}
