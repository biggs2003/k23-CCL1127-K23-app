import SwiftUI

struct CategoryBadgeView: View {
    let category: HeightCategory

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: category.systemIcon)
            Text(category.label)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(category.color)
        .clipShape(Capsule())
    }
}
