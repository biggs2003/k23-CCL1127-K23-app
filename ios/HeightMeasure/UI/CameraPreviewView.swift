import SwiftUI
import RealityKit
import ARKit

struct CameraPreviewView: UIViewRepresentable {
    @ObservedObject var sessionManager: ARSessionManager
    var onTap: (CGPoint, CGSize) -> Void

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        arView.session = sessionManager.session
        arView.renderOptions = [.disableDepthOfField, .disableMotionBlur]

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tap)

        context.coordinator.arView = arView
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.onTap = onTap
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onTap: onTap)
    }

    class Coordinator: NSObject {
        var onTap: (CGPoint, CGSize) -> Void
        weak var arView: ARView?

        init(onTap: @escaping (CGPoint, CGSize) -> Void) {
            self.onTap = onTap
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView else { return }
            let location = gesture.location(in: arView)
            onTap(location, arView.bounds.size)
        }
    }
}
