import ARKit
import Combine

class ARSessionManager: NSObject, ObservableObject {
    let session = ARSession()
    @Published var currentFrame: ARFrame?
    @Published var trackingState: ARCamera.TrackingState = .notAvailable

    override init() {
        super.init()
        session.delegate = self
    }

    func startSession() {
        guard ARWorldTrackingConfiguration.isSupported else { return }
        let config = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.smoothedSceneDepth) {
            config.frameSemantics = [.smoothedSceneDepth]
        } else {
            config.frameSemantics = [.sceneDepth]
        }
        config.planeDetection = [.horizontal, .vertical]
        session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }

    func pauseSession() {
        session.pause()
    }
}

extension ARSessionManager: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        DispatchQueue.main.async {
            self.currentFrame = frame
            self.trackingState = frame.camera.trackingState
        }
    }
}
