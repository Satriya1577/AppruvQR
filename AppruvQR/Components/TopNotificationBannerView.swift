//
//  TopNotificationBannerView.swift
//  AppruvQR
//

import SwiftUI

struct TopNotificationBannerView: View {
    let notification: NotificationModel
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            NotificationCardView(notification: notification)

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.white.opacity(0.35))
        }
        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)
    }
}

#Preview {
    TopNotificationBannerView(
        notification: NotificationModel(
            eventKey: "preview-banner",
            title: "Task Completed",
            subtitle: "Finalize onboarding flow",
            createdAt: .now,
            kind: "taskCompleted"
        ),
        onDismiss: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
