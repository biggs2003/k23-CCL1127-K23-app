import simd

extension SIMD4 where Scalar == Float {
    var xyz: SIMD3<Float> { SIMD3(x, y, z) }
}

extension float4x4 {
    var translation: SIMD3<Float> { columns.3.xyz }
}
