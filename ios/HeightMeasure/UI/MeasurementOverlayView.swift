import SwiftUI
import ARKit

struct MeasurementOverlayView: View {
    @ObservedObject var session: MeasurementSession
    @ObservedObject var sessionManager: ARSessionManager
    let viewportSize: CGSize

    var body: some View {
        ZStack {
            if let frame = sessionManager.currentFrame {
                Canvas { context, size in
                    drawMeasurement(context: context, size: size, frame: frame)
                }
                .allowsHitTesting(false)
            }

            VStack {
                trackingBanner
                    .padding(.top, 60)
                Spacer()
                instructionBanner
                    .padding(.bottom, 120)
            }
            .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private var trackingBanner: some View {
        switch sessionManager.trackingState {
        case .limited(let reason):
            Text(trackingWarning(for: reason))
                .font(.caption)
                .foregroundStyle(.white)
                .padding(8)
                .background(.black.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    private var instructionBanner: some View {
        switch session.tapState {
        case .idle:
            banner("Tap the bottom of the object")
        case .bottomPlaced:
            banner("Tap the top of the object")
        case .complete:
            EmptyView()
        }
    }

    private func banner(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.black.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func drawMeasurement(context: GraphicsContext, size: CGSize, frame: ARFrame) {
        switch session.tapState {
        case .idle:
            drawCrosshair(context: context, at: CGPoint(x: size.width / 2, y: size.height / 2))

        case .bottomPlaced(let bottom):
            let pt = frame.camera.projectPoint(bottom, orientation: .portrait, viewportSize: size)
            if size.contains(pt) { drawDot(context: context, at: pt, color: .green) }

        case .complete(let result):
            let bottomPt = frame.camera.projectPoint(result.bottomPoint, orientation: .portrait, viewportSize: size)
            let topPt    = frame.camera.projectPoint(result.topPoint,    orientation: .portrait, viewportSize: size)

            var line = Path()
            line.move(to: bottomPt)
            line.addLine(to: topPt)
            context.stroke(line, with: .color(.white.opacity(0.9)), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))

            if size.contains(bottomPt) { drawDot(context: context, at: bottomPt, color: .green) }
            if size.contains(topPt)    { drawDot(context: context, at: topPt,    color: .orange) }

            let mid = CGPoint(x: (bottomPt.x + topPt.x) / 2 + 16,
                              y: (bottomPt.y + topPt.y) / 2)
            context.draw(
                Text(String(format: "%.2f m", result.verticalHeight))
                    .font(.system(.headline, design: .rounded).bold())
                    .foregroundStyle(.white),
                at: mid,
                anchor: .leading
            )
        }
    }

    private func drawCrosshair(context: GraphicsContext, at p: CGPoint) {
        let r: CGFloat = 18
        var h = Path(); h.move(to: CGPoint(x: p.x - r, y: p.y)); h.addLine(to: CGPoint(x: p.x + r, y: p.y))
        var v = Path(); v.move(to: CGPoint(x: p.x, y: p.y - r)); v.addLine(to: CGPoint(x: p.x, y: p.y + r))
        context.stroke(h, with: .color(.white.opacity(0.8)), lineWidth: 2)
        context.stroke(v, with: .color(.white.opacity(0.8)), lineWidth: 2)
    }

    private func drawDot(context: GraphicsContext, at p: CGPoint, color: Color) {
        let rect = CGRect(x: p.x - 9, y: p.y - 9, width: 18, height: 18)
        context.fill(Circle().path(in: rect), with: .color(color))
        context.stroke(Circle().path(in: rect), with: .color(.white), lineWidth: 2)
    }

    private func trackingWarning(for reason: ARCamera.TrackingState.Reason) -> String {
        switch reason {
        case .initializing:        return "Initialising AR…"
        case .excessiveMotion:     return "Slow down — too much motion"
        case .insufficientFeatures: return "Point at a textured surface"
        case .relocalizing:        return "Relocalising…"
        @unknown default:          return "Limited tracking"
        }
    }
}

private extension CGSize {
    func contains(_ point: CGPoint) -> Bool {
        point.x >= 0 && point.x <= width && point.y >= 0 && point.y <= height
    }
}
