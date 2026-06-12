import ARKit

enum LiDARCapabilityChecker {
    static var isLiDARAvailable: Bool {
        ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth)
    }
}
