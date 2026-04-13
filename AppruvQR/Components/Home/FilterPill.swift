import SwiftUI

struct FilterPill: View {
    let tab: FilterTab
    let isSelected: Bool
    var badgeCount: Int = 0
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: tab.icon)
                    .font(.system(size: 16, weight: .semibold))

                if isSelected {
                    Text(tab.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)
                        .fixedSize()
                }
            }
            .frame(maxWidth: isSelected ? .infinity : nil)
            .padding(.horizontal, isSelected ? 12 : 16)
            .padding(.vertical, 9)
            .background(isSelected ? tab.activeColor : Color.black.opacity(0.08))
            .foregroundColor(isSelected ? .white : .gray.opacity(0.8))
            .clipShape(Capsule())
            .overlay(alignment: .topTrailing) {
                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
