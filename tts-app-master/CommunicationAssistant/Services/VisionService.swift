import Foundation
import Vision
import Combine
import CoreMedia

@MainActor
final class VisionService: ObservableObject {
    @Published private(set) var isProcessing = false
    @Published private(set) var isTypingActive = false
    @Published private(set) var handObservations: [VNHumanHandPoseObservation] = []
    
    private let gestureRecognizer = GestureRecognizer()
    private let gestureClassifier = GestureClassifier()
    
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
            }
        }
        
        gestureRecognizer.onKeystrokeDetected = { [weak self] in
            Task { @MainActor in
                guard let self = self, self.isTypingActive,
                      let observation = self.handObservations.first,
                      let character = self.gestureClassifier.classify(observation: observation) else {
                    return
                }
                self.onCharacterTyped?(character)
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
        // Run counter on a non-isolated context if needed, but since it's just an int
        // we'll handle isolation via Task or just move it to a dedicated actor later if complex.
        // For MVP, we'll keep it simple.
        
        let handPoseRequest = VNDetectHumanHandPoseRequest()
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
                        self.gestureRecognizer.process(observations: results)
                    }
                }
            }
        } catch {
            print("Vision error: \(error)")
        }
    }
}
