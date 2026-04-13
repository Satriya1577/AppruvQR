//
//  NotificationCardView.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 08/04/26.
//

import SwiftUI

struct NotificationCardView: View {
    let notification: NotificationModel

    private var style: (iconName: String, iconColor: Color) {
        switch notification.kind {
        case "dueSoon":
            return ("clock.badge.exclamationmark", .alertRed)
        case "taskCompleted":
            return ("checkmark.circle.fill", .green)
        case "progressShared":
            return ("square.and.arrow.up.circle.fill", .blueThis)
        case "reflectionShared":
            return ("text.bubble.fill", .blue3)
        case "streakAcquired":
            return ("flame.fill", .streakOrange)
        default:
            return ("bell.fill", .gray)
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: style.iconName)
                .font(.title3)
                .foregroundStyle(style.iconColor)
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
    }
}

#Preview {
    List {
        ForEach(NotificationModel.previewSamples) { notification in
            NotificationCardView(notification: notification)
        }
    }
}
