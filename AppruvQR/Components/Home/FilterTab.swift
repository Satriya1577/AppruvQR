import SwiftUI

enum FilterTab: String, CaseIterable {
    case primary = "Primary"
    case allTask = "All Task"
    case completed = "Completed"
    case missed = "Missed"

    var icon: String {
        switch self {
        case .primary: return "person.fill"
        case .allTask: return "doc.text.fill"
        case .completed: return "checklist"
        case .missed: return "exclamationmark.triangle.fill"
        }
    }

    var activeColor: Color {
        switch self {
        case .primary: return .blue
        case .allTask: return Color(white: 0.2)
        case .completed: return Color.green.opacity(0.8)
        case .missed: return Color(red: 0.85, green: 0.3, blue: 0.4)
        }
    }
}
