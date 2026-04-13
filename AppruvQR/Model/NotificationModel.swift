//
//  NotificationModel.swift
//  AppruvQR
//
//  Created by Satriya Handha Wibowo on 07/04/26.
//

import Foundation
import SwiftData

@Model
final class NotificationModel {
    @Attribute(.unique) var eventKey: String
    var title: String
    var subtitle: String
    var createdAt: Date
    var kind: String

    init(eventKey: String, title: String, subtitle: String, createdAt: Date, kind: String) {
        self.eventKey = eventKey
        self.title = title
        self.subtitle = subtitle
        self.createdAt = createdAt
        self.kind = kind
    }
}

extension NotificationModel {
    static var previewSamples: [NotificationModel] {
        [
            NotificationModel(
                eventKey: "dummy_due_01",
                title: "Task Due Soon! Start Now.",
                subtitle: "Menyelesaikan UI Design Aplikasi AppruvQR",
                createdAt: Date(),
                kind: "dueSoon"
            ),
            NotificationModel(
                eventKey: "dummy_completed_02",
                title: "Task Completed",
                subtitle: "Riset Kompetitor Aplikasi",
                createdAt: Date().addingTimeInterval(-3600),
                kind: "taskCompleted"
            )
        ]
    }
}
