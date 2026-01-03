import SwiftUI
import AVFoundation
import Vision
#if os(iOS)
import UIKit
#endif

/// View for calibrating the air QWERTY keyboard by capturing home row hand positions
struct KeyboardCalibrationView: View {
    @ObservedObject var cameraManager: CameraManager
    @ObservedObject var visionService: VisionService
    @ObservedObject var keyboardMapper: KeyboardMapper
    @Environment(\.dismiss) private var dismiss

    @State private var calibrationState: CalibrationState = .waiting
    @State private var countdown: Int = 3
    @State private var leftHandDetected = false
    @State private var rightHandDetected = false
    @State private var statusMessage = "Position your hands on the home row"

    enum CalibrationState {
        case waiting      // Waiting for both hands
        case countdown    // Counting down before capture
        case capturing    // Capturing calibration data
        case success      // Calibration complete
        case failed       // Calibration failed
    }

    var body: some View {
        ZStack {
            // Camera preview
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()

            // Hand landmark overlay
            HandLandmarkOverlay(observations: visionService.handObservations)

            // Calibration guide overlay
            CalibrationGuideOverlay(
                leftDetected: leftHandDetected,
                rightDetected: rightHandDetected
            )

            // UI overlay
            VStack {
                // Header
                Text("Keyboard Calibration")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.top, 60)

                Spacer()

                // Status and instructions
                VStack(spacing: 16) {
                    // Hand detection status
                    HStack(spacing: 20) {
                        HandStatusIndicator(
                            label: "Left Hand",
                            isDetected: leftHandDetected
                        )
                        HandStatusIndicator(
                            label: "Right Hand",
                            isDetected: rightHandDetected
                        )
                    }

                    // Status message
                    Text(statusMessage)
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(.black.opacity(0.7))
                        .cornerRadius(10)

                    // Countdown or action button
                    if calibrationState == .countdown {
                        Text("\(countdown)")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(.white)
                    } else if calibrationState == .success {
                        Button("Done") {
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    } else if calibrationState == .failed {
                        Button("Try Again") {
                            resetCalibration()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }

                    // Instructions
                    instructionsView
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            startCalibration()
        }
        .onDisappear {
            cameraManager.stop()
            visionService.stop()
        }
    }

    private var instructionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Instructions:")
                .font(.caption.bold())
            Text("1. Place phone flat on table, camera facing up")
            Text("2. Hold hands above camera as if typing")
            Text("3. Place fingers on imaginary F and J keys")
            Text("4. Keep hands still until calibration completes")
        }
        .font(.caption)
        .foregroundColor(.white.opacity(0.8))
        .padding()
        .background(.black.opacity(0.6))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    // MARK: - Calibration Logic

    private func startCalibration() {
        let service = visionService
        cameraManager.start()
        service.start()

        cameraManager.onFrameCaptured = { buffer in
            service.process(sampleBuffer: buffer)
            Task { @MainActor in
                updateHandDetection()
            }
        }
    }

    private func updateHandDetection() {
        let observations = visionService.handObservations

        // Check hand detection by chirality
        leftHandDetected = observations.contains { $0.chirality == .left }
        rightHandDetected = observations.contains { $0.chirality == .right }

        // If both hands detected for first time, start countdown
        if leftHandDetected && rightHandDetected && calibrationState == .waiting {
            startCountdown()
        }

        // If hands lost during countdown, reset
        if calibrationState == .countdown && (!leftHandDetected || !rightHandDetected) {
            resetCalibration()
            statusMessage = "Hands lost. Please hold still."
        }
    }

    private func startCountdown() {
        calibrationState = .countdown
        countdown = 3
        statusMessage = "Hold still..."

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            Task { @MainActor in
                countdown -= 1
                if countdown <= 0 {
                    timer.invalidate()
                    performCalibration()
                }
            }
        }
    }

    private func performCalibration() {
        calibrationState = .capturing
        statusMessage = "Capturing..."

        let observations = visionService.handObservations

        guard let leftObs = observations.first(where: { $0.chirality == .left }),
              let rightObs = observations.first(where: { $0.chirality == .right }) else {
            calibrationFailed("Could not detect both hands")
            return
        }

        // Perform calibration
        let success = keyboardMapper.calibrate(
            leftObservation: leftObs,
            rightObservation: rightObs
        )

        if success {
            calibrationState = .success
            statusMessage = "Calibration complete!"
            // Haptic feedback
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif
        } else {
            calibrationFailed("Could not extract finger positions")
        }
    }

    private func calibrationFailed(_ reason: String) {
        calibrationState = .failed
        statusMessage = "Calibration failed: \(reason)"
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }

    private func resetCalibration() {
        calibrationState = .waiting
        countdown = 3
        statusMessage = "Position your hands on the home row"
    }
}

// MARK: - Supporting Views

struct HandStatusIndicator: View {
    let label: String
    let isDetected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isDetected ? Color.green : Color.red)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.black.opacity(0.6))
        .cornerRadius(20)
    }
}

struct CalibrationGuideOverlay: View {
    let leftDetected: Bool
    let rightDetected: Bool

    var body: some View {
        GeometryReader { geometry in
            let centerY = geometry.size.height * 0.5
            let leftX = geometry.size.width * 0.35
            let rightX = geometry.size.width * 0.65

            // Left hand guide (F key position)
            Circle()
                .stroke(leftDetected ? Color.green : Color.white.opacity(0.5), lineWidth: 3)
                .frame(width: 60, height: 60)
                .position(x: leftX, y: centerY)

            Text("F")
                .font(.title2.bold())
                .foregroundColor(leftDetected ? .green : .white.opacity(0.5))
                .position(x: leftX, y: centerY)

            // Right hand guide (J key position)
            Circle()
                .stroke(rightDetected ? Color.green : Color.white.opacity(0.5), lineWidth: 3)
                .frame(width: 60, height: 60)
                .position(x: rightX, y: centerY)

            Text("J")
                .font(.title2.bold())
                .foregroundColor(rightDetected ? .green : .white.opacity(0.5))
                .position(x: rightX, y: centerY)

            // Home row line indicator
            Path { path in
                path.move(to: CGPoint(x: leftX - 100, y: centerY))
                path.addLine(to: CGPoint(x: rightX + 100, y: centerY))
            }
            .stroke(Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
        }
    }
}
