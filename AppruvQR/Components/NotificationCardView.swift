//
//  NotificationCardView.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 08/04/26.
//

import SwiftUI
import SwiftData

struct NotificationCardView: View {
    // Card ini hanya butuh 1 data notifikasi untuk ditampilkan
    let notification: NotificationModel
    
    var body: some View {
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
        .contentShape(Rectangle()) // Memastikan area kosong tetap bisa di-tap/swipe
    }
}

#Preview {
    // 1. Data Dummy Tipe Peringatan (dueToday)
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
   
    List {
        NotificationCardView(notification: dummyWarning)
        NotificationCardView(notification: dummySuccess)
    }
}
