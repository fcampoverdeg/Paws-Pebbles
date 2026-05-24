import SwiftUI
import CoreMotion
import Combine

class ParallaxMotionManager: ObservableObject {
    @Published var xOffset: CGFloat = 0
    @Published var yOffset: CGFloat = 0

    private let motionManager = CMMotionManager()
    private let intensity: CGFloat = 20 // how far the image shifts in points

    func start() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 30.0

        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }

            let roll = CGFloat(motion.attitude.roll)   // tilt left/right
            let pitch = CGFloat(motion.attitude.pitch)  // tilt forward/back

            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8)) {
                self.xOffset = roll * self.intensity
                self.yOffset = (pitch - 0.5) * self.intensity // offset for hand-held angle
            }
        }
    }

    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}
