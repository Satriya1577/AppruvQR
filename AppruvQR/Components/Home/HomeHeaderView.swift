import SwiftUI

struct HomeHeaderView: View {
    let appBackground: Color
    let streakCount: Int
    @Binding var selectedFilter: FilterTab
    let missedTaskCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()

                HStack(spacing: 12) {
                    NavigationLink(destination: StreakView()) {
                        HStack(spacing: 4) {
                            Text("\(streakCount)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.orange)

                            Image(systemName: "flame.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.orange)
                                .shadow(color: .orange.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(Capsule())
                    }

                    NavigationLink(destination: NotificationView()) {
                        Image(systemName: "bell")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .clipShape(Circle())
                    }

                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
            }

            Text("All Tasks")
                .font(.system(size: 34, weight: .bold))

            HStack(spacing: 7) {
                ForEach(FilterTab.allCases, id: \.self) { tab in
                    FilterPill(
                        tab: tab,
                        isSelected: selectedFilter == tab,
                        badgeCount: tab == .missed ? missedTaskCount : 0
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedFilter = tab
                        }
                    }
                }
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .background(appBackground)
    }
}
