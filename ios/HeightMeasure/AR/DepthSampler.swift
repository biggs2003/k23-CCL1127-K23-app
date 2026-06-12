import ARKit
import simd

enum DepthSampler {
    /// Converts a screen tap to a world-space 3D point using the LiDAR depth map.
    /// - Parameters:
    ///   - screenPoint: Tap location in view points (origin top-left, portrait orientation).
    ///   - frame: The current ARFrame containing depth data and camera info.
    ///   - viewportSize: The size of the AR view in points.
    /// - Returns: World-space point, or nil if depth is unavailable/invalid at that pixel.
    static func worldPoint(
        for screenPoint: CGPoint,
        in frame: ARFrame,
        viewportSize: CGSize
    ) -> SIMD3<Float>? {
        guard let depthData = frame.smoothedSceneDepth ?? frame.sceneDepth else { return nil }

        let depthMap = depthData.depthMap
        let depthWidth  = CVPixelBufferGetWidth(depthMap)
        let depthHeight = CVPixelBufferGetHeight(depthMap)

        // Normalize screen point to [0,1]² in display space
        let normalizedDisplay = CGPoint(
            x: screenPoint.x / viewportSize.width,
            y: screenPoint.y / viewportSize.height
        )

        // Map from display-space [0,1]² to camera-image-space [0,1]²
        // displayTransform maps image coords → display coords, so we invert it.
        let displayTransform = frame.displayTransform(for: .portrait, viewportSize: viewportSize)
        let imagePoint = normalizedDisplay.applying(displayTransform.inverted())

        // Sample the depth map (native camera orientation, typically landscape)
        let px = max(0, min(depthWidth  - 1, Int(imagePoint.x * CGFloat(depthWidth))))
        let py = max(0, min(depthHeight - 1, Int(imagePoint.y * CGFloat(depthHeight))))

        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(depthMap, .readOnly) }

        guard let base = CVPixelBufferGetBaseAddress(depthMap) else { return nil }
        let bytesPerRow = CVPixelBufferGetBytesPerRow(depthMap)
        let depth = base
            .advanced(by: py * bytesPerRow + px * MemoryLayout<Float32>.size)
            .load(as: Float32.self)

        guard depth > 0.01, depth.isFinite else { return nil }

        // Unproject to camera space using the full-resolution intrinsics.
        // imagePoint is normalised [0,1] in camera-image space; scale to pixel coords.
        let imageResolution = frame.camera.imageResolution
        let camPx = Float(imagePoint.x) * Float(imageResolution.width)
        let camPy = Float(imagePoint.y) * Float(imageResolution.height)

        let intrinsics = frame.camera.intrinsics  // column-major: [col][row]
        let fx = intrinsics[0][0], cx = intrinsics[2][0]
        let fy = intrinsics[1][1], cy = intrinsics[2][1]

        // ARKit camera space: Y up, -Z into the scene
        let xCam = (camPx - cx) / fx * depth
        let yCam = (camPy - cy) / fy * depth
        let cameraSpacePoint = SIMD4<Float>(xCam, yCam, -depth, 1)

        return (frame.camera.transform * cameraSpacePoint).xyz
    }
}
