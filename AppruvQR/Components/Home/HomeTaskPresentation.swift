$caveimport Foundation

enum HomeTaskPresentation {
    static func filteredTasks(from tasks: [TaskModel], selectedFilter: FilterTab) -> [TaskModel] {
        switch selectedFilter {
        case .primary:
            let pinned = tasks.filter { $0.isPinned && $0.status != "completed" }.prefix(3)
            let pinnedIds = Set(pinned.map(\.taskId))

            let today = tasks.filter {
                Calendar.current.isDateInToday($0.dueDate)
                    && $0.status == "todo"
                    && !pinnedIds.contains($0.taskId)
            }
            return Array(pinned) + today

        case .allTask:
            return tasks.filter { $0.status == "todo" }

        case .completed:
            return tasks.filter { $0.status == "completed" }

        case .missed:
            return tasks.filter { $0.status == "missed" }
        }
    }

    static func groupedTasks(from tasks: [TaskModel], selectedFilter: FilterTab) -> [(String, [TaskModel])] {
        let tasksToGroup = selectedFilter == .primary ? tasks.filter { !$0.isPinned } : tasks

        let grouped = Dictionary(grouping: tasksToGroup) { task in
            dayFormatter.string(from: task.dueDate)
        }

        let sortedKeys = grouped.keys.sorted {
            let d1 = dayFormatter.date(from: $0) ?? .distantPast
            let d2 = dayFormatter.date(from: $1) ?? .distantPast
            return d1 < d2
        }

        return sortedKeys.compactMap { key in
            guard let values = grouped[key] else { return nil }
            return (key, values)
        }
    }

    static func dateHeader(for dateString: String, selectedFilter: FilterTab) -> String {
        guard let date = dayFormatter.date(from: dateString) else { return dateString }
        let fullDate = titleFormatter.string(from: date)

        guard selectedFilter == .primary else {
            return fullDate
        }

        if Calendar.current.isDateInToday(date) {
            return "Today, " + fullDate
        }
        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday, " + fullDate
        }
        if Calendar.current.isDateInTomorrow(date) {
            return "Tomorrow, " + fullDate
        }
        return fullDate
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()

    private static let titleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
}
