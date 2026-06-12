import ARKit
import RealityKit

/// Resolves a screen tap to a world-space 3D point.
/// Uses LiDAR depth sampling on supported hardware.
class RaycastCoordinator {
    weak var sessionManager: ARSessionManager?

    func worldPoint(for screenPoint: CGPoint, viewportSize: CGSize) -> SIMD3<Float>? {
        guard let frame = sessionManager?.currentFrame else { return nil }
        return DepthSampler.worldPoint(for: screenPoint, in: frame, viewportSize: viewportSize)
    }
}
