import Foundation
import Vision
import Combine
import CoreMedia
#if os(iOS)
import UIKit
#endif

enum TypingMode: String {
    case gesture  // Original profile-based gesture recognition
    case qwerty   // QWERTY keyboard air typing
}

@MainActor
final class VisionService: ObservableObject {
    @Published private(set) var isProcessing = false
    @Published private(set) var isTypingActive = false
    @Published private(set) var handObservations: [VNHumanHandPoseObservation] = []
    @Published var typingMode: TypingMode = .gesture
    @Published private(set) var lastTypedKey: String?

    private let gestureRecognizer = GestureRecognizer()
    private let gestureClassifier = GestureClassifier()

    // QWERTY mode components
    let keyboardMapper = KeyboardMapper()

    // Performance optimization: process every N frames
    private var frameCounter = 0
    private let frameSkipCount = 3

    var onCharacterTyped: ((String) -> Void)?
    
    init() {
        setupGestureRecognizer()
    }

    func updateProfiles(_ profiles: [HandProfile]) {
        gestureClassifier.updateProfiles(profiles)
    }

    private func setupGestureRecognizer() {
        gestureRecognizer.onActivationGestureDetected = { [weak self] in
            Task { @MainActor in
                self?.isTypingActive.toggle()
                if self?.isTypingActive == false {
                    self?.gestureRecognizer.resetFingerTracking()
                }
            }
        }

        // Legacy gesture mode keystroke handling
        gestureRecognizer.onKeystrokeDetected = { [weak self] in
            Task { @MainActor in
                guard let self = self,
                      self.typingMode == .gesture,
                      self.isTypingActive,
                      let observation = self.handObservations.first,
                      let character = self.gestureClassifier.classify(observation: observation) else {
                    return
                }
                self.lastTypedKey = character
                self.onCharacterTyped?(character)
            }
        }

        // QWERTY mode per-finger tap handling
        gestureRecognizer.onFingerTap = { [weak self] chirality, finger, observation in
            Task { @MainActor in
                guard let self = self,
                      self.typingMode == .qwerty,
                      self.isTypingActive,
                      self.keyboardMapper.isCalibrated else {
                    return
                }

                // Map finger to KeyboardMapper.Finger type
                let mapperFinger: KeyboardMapper.Finger? = {
                    switch finger {
                    case .indexTip: return .index
                    case .middleTip: return .middle
                    case .ringTip: return .ring
                    case .littleTip: return .pinky
                    default: return nil
                    }
                }()

                guard let finger = mapperFinger else { return }

                let hand: KeyboardMapper.HandSide = chirality == .left ? .left : .right

                if let character = self.keyboardMapper.getKey(
                    observation: observation,
                    finger: finger,
                    hand: hand
                ) {
                    self.lastTypedKey = character
                    self.onCharacterTyped?(character)

                    // Haptic feedback
                    #if os(iOS)
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    #endif
                }
            }
        }
    }
    
    func start() {
        isProcessing = true
        frameCounter = 0
    }
    
    func stop() {
        isProcessing = false
        isTypingActive = false
        handObservations = []
    }
    
    nonisolated func process(sampleBuffer: CMSampleBuffer) {
        // Detect up to 2 hands for QWERTY mode
        let handPoseRequest = VNDetectHumanHandPoseRequest()
        handPoseRequest.maximumHandCount = 2

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([handPoseRequest])
            if let results = handPoseRequest.results {
                Task { @MainActor in
                    guard self.isProcessing else { return }

                    // Throttle updates to the UI and classification
                    self.frameCounter += 1
                    if self.frameCounter >= self.frameSkipCount {
                        self.frameCounter = 0
                        self.handObservations = results

                        // Route to appropriate processor based on mode
                        switch self.typingMode {
                        case .gesture:
                            self.gestureRecognizer.process(observations: results)
                        case .qwerty:
                            self.gestureRecognizer.processForQwerty(observations: results)
                        }
                    }
                }
            }
        } catch {
            print("Vision error: \(error)")
        }
    }

    /// Toggle between typing modes
    func setTypingMode(_ mode: TypingMode) {
        typingMode = mode
        isTypingActive = false
        lastTypedKey = nil
        gestureRecognizer.resetFingerTracking()
    }
}
