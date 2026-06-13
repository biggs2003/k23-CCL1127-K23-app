import simd

enum HeightCalculator {
    static func verticalHeight(bottom: SIMD3<Float>, top: SIMD3<Float>) -> Float {
        abs(top.y - bottom.y)
    }

    static func euclideanDistance(a: SIMD3<Float>, b: SIMD3<Float>) -> Float {
        simd_distance(a, b)
    }
}
