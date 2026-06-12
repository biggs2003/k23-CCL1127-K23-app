import SwiftUI

struct ResultCardView: View {
    let result: MeasurementResult
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(String(format: "%.2f m", result.verticalHeight))
                .font(.system(size: 64, weight: .bold, design: .rounded))

            CategoryBadgeView(category: result.category)

            if result.showsSlantDistance {
                Text(String(format: "Slant distance: %.2f m", result.euclideanDistance))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(result.timestamp, style: .time)
                .font(.caption)
                .foregroundStyle(.tertiary)

            Button("Measure Again", action: onReset)
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}
