import Foundation
import Vision

@MainActor
final class GestureRecognizer: ObservableObject {
    @Published var isPalmDetected = false
    private var palmDetectionStartTime: Date?
    private let detectionThreshold: TimeInterval = 2.0
    
    // Keystroke detection state
    private var lastWristPosition: CGPoint?
    private let tapThreshold: CGFloat = 0.05 // Normalized distance
    private var isTapGestureActive = false
    
    var onActivationGestureDetected: (() -> Void)?
    var onKeystrokeDetected: (() -> Void)?
    
    func process(observations: [VNHumanHandPoseObservation]) {
        guard let observation = observations.first else {
            resetPalmDetection()
            lastWristPosition = nil
            return
        }
        
        // Check for activation gesture
        if isOpenPalm(observation) {
            handlePalmDetected()
        } else {
            resetPalmDetection()
        }
        
        // Check for keystroke (tap) gesture
        detectKeystroke(observation)
    }
    
    private func isOpenPalm(_ observation: VNHumanHandPoseObservation) -> Bool {
        guard let wrist = try? observation.recognizedPoint(.wrist),
              let thumbTip = try? observation.recognizedPoint(.thumbTip),
              let indexTip = try? observation.recognizedPoint(.indexTip),
              let middleTip = try? observation.recognizedPoint(.middleTip),
              let ringTip = try? observation.recognizedPoint(.ringTip),
              let littleTip = try? observation.recognizedPoint(.littleTip) else {
            return false
        }
        
        let confidenceThreshold: Float = 0.5
        let points = [wrist, thumbTip, indexTip, middleTip, ringTip, littleTip]
        guard points.allSatisfy({ $0.confidence > confidenceThreshold }) else { return false }
        
        let isExtended = thumbTip.location.y > wrist.location.y &&
                         indexTip.location.y > wrist.location.y &&
                         middleTip.location.y > wrist.location.y &&
                         ringTip.location.y > wrist.location.y &&
                         littleTip.location.y > wrist.location.y
        
        return isExtended
    }
    
    private func detectKeystroke(_ observation: VNHumanHandPoseObservation) {
        // A keystroke is detected by a rapid "forward" movement (y decrease in normalized bottom-up coordinates 
        // if we assume camera is front-facing and "forward" is towards the screen, but Vision y is up.
        // Actually, let's look for a rapid decrease in 'y' of the index tip relative to the wrist 
        // OR a rapid 'z' change if depth was available.
        // For 2D, a rapid "pecking" motion (down then up) works.
        
        guard let indexTip = try? observation.recognizedPoint(.indexTip),
              indexTip.confidence > 0.7 else {
            return
        }
        
        let currentPos = indexTip.location
        
        if let lastPos = lastWristPosition {
            let dy = lastPos.y - currentPos.y // Change in vertical position
            
            if dy > tapThreshold && !isTapGestureActive {
                // Rapid downward movement detected
                isTapGestureActive = true
                onKeystrokeDetected?()
            } else if dy < -tapThreshold {
                // Hand moved back up
                isTapGestureActive = false
            }
        }
        
        lastWristPosition = currentPos
    }
    
    private func handlePalmDetected() {
        if !isPalmDetected {
            isPalmDetected = true
            palmDetectionStartTime = Date()
        } else if let startTime = palmDetectionStartTime,
                  Date().timeIntervalSince(startTime) >= detectionThreshold {
            onActivationGestureDetected?()
            resetPalmDetection()
        }
    }
    
    private func resetPalmDetection() {
        isPalmDetected = false
        palmDetectionStartTime = nil
    }
}