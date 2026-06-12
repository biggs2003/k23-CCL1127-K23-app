import ARKit
import Combine

enum TapState {
    case idle
    case bottomPlaced(point: SIMD3<Float>)
    case complete(result: MeasurementResult)
}

class MeasurementSession: ObservableObject {
    @Published var tapState: TapState = .idle
    @Published var completedResult: MeasurementResult?

    private let categories: [HeightCategory]

    init(categories: [HeightCategory] = HeightCategory.defaults) {
        self.categories = categories
    }

    func recordTap(worldPoint: SIMD3<Float>) {
        switch tapState {
        case .idle:
            tapState = .bottomPlaced(point: worldPoint)

        case .bottomPlaced(let bottom):
            let vertical = HeightCalculator.verticalHeight(bottom: bottom, top: worldPoint)
            let euclidean = HeightCalculator.euclideanDistance(a: bottom, b: worldPoint)
            let result = MeasurementResult(
                id: UUID(),
                verticalHeight: vertical,
                euclideanDistance: euclidean,
                category: HeightCategory.category(for: vertical, categories: categories),
                bottomPoint: bottom,
                topPoint: worldPoint,
                timestamp: Date()
            )
            tapState = .complete(result: result)
            completedResult = result

        case .complete:
            break
        }
    }

    func reset() {
        tapState = .idle
        completedResult = nil
    }
}
