import SwiftUI
import ARKit

struct ContentView: View {
    @StateObject private var sessionManager = ARSessionManager()
    @StateObject private var measurementSession = MeasurementSession()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraPreviewView(sessionManager: sessionManager) { screenPoint, viewportSize in
                    handleTap(at: screenPoint, viewportSize: viewportSize)
                }

                MeasurementOverlayView(
                    session: measurementSession,
                    sessionManager: sessionManager,
                    viewportSize: geometry.size
                )
            }
        }
        .ignoresSafeArea()
        .onAppear { sessionManager.startSession() }
        .onDisappear { sessionManager.pauseSession() }
        .sheet(item: $measurementSession.completedResult, onDismiss: {
            measurementSession.reset()
        }) { result in
            ResultCardView(result: result) {
                measurementSession.reset()
            }
            .presentationDetents([.medium])
        }
    }

    private func handleTap(at screenPoint: CGPoint, viewportSize: CGSize) {
        guard let frame = sessionManager.currentFrame else { return }
        guard case .normal = frame.camera.trackingState else { return }
        if case .complete = measurementSession.tapState { return }

        if let worldPoint = DepthSampler.worldPoint(for: screenPoint, in: frame, viewportSize: viewportSize) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            measurementSession.recordTap(worldPoint: worldPoint)
        }
    }
}
