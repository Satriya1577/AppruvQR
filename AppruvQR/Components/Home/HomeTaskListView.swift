import SwiftUI
import UIKit

struct HomeTaskListView: View {
    let selectedFilter: FilterTab
    let filteredTasks: [TaskModel]
    let groupedTasks: [(String, [TaskModel])]
    let formatDateHeader: (String) -> String
    let onComplete: (TaskModel) -> Void
    let onStreakUpdated: () -> Void
    let onProgressShared: (TaskModel) -> Void

    var body: some View {
        List {
            if filteredTasks.isEmpty {
                Text("No tasks yet. \n \nClick the blue button below to create a new task!")
                    .foregroundColor(.gray)
                    .padding(.top, 20)
                    .padding(16)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                if selectedFilter == .primary {
                    let pinnedTasks = filteredTasks.filter { $0.isPinned }
                    if !pinnedTasks.isEmpty {
                        Section(
                            header: Text("Pinned")
                                .font(.system(size: 18, weight: .bold))
                                .textCase(nil)
                                .padding(.bottom, -8)
                        ) {
                            ForEach(Array(pinnedTasks.enumerated()), id: \.element.taskId) { index, task in
                                SwipeableTaskRow(
                                    task: task,
                                    onComplete: { onComplete(task) },
                                    onStreakUpdated: onStreakUpdated,
                                    onProgressShared: onProgressShared
                                )
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(
                                    EdgeInsets(top: index == 0 ? 0 : 4, leading: 20, bottom: 4, trailing: 20)
                                )
                            }
                        }
                    }
                }

                ForEach(groupedTasks, id: \.0) { dateGroup in
                    Section(
                        header: Text(formatDateHeader(dateGroup.0))
                            .font(.system(size: 18, weight: .bold))
                            .textCase(nil)
                            .padding(.bottom, -8)
                    ) {
                        ForEach(Array(dateGroup.1.enumerated()), id: \.element.taskId) { index, task in
                            SwipeableTaskRow(
                                task: task,
                                onComplete: { onComplete(task) },
                                onStreakUpdated: onStreakUpdated,
                                onProgressShared: onProgressShared
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(
                                EdgeInsets(top: index == 0 ? 0 : 4, leading: 20, bottom: 4, trailing: 20)
                            )
                        }
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .simultaneousGesture(
            DragGesture(minimumDistance: 4).onChanged { _ in
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
        )
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .padding(.top, -8)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 84)
        }
    }
}
