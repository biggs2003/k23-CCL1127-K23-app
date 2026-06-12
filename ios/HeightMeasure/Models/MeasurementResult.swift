import Foundation
import simd

struct MeasurementResult: Identifiable, Codable, Equatable {
    let id: UUID
    let verticalHeight: Float
    let euclideanDistance: Float
    let category: HeightCategory
    let bottomPoint: SIMD3<Float>
    let topPoint: SIMD3<Float>
    let timestamp: Date

    var showsSlantDistance: Bool {
        abs(euclideanDistance - verticalHeight) > 0.02
    }
}
