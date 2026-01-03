import Foundation
import Vision

@MainActor
final class GestureClassifier {
    private var profiles: [HandProfile] = []
    
    func updateProfiles(_ newProfiles: [HandProfile]) {
        self.profiles = newProfiles
    }
    
    func classify(observation: VNHumanHandPoseObservation) -> String? {
        guard !profiles.isEmpty else { return nil }
        
        let currentLandmarks = extractLandmarks(from: observation)
        guard !currentLandmarks.isEmpty else { return nil }
        
        var bestMatch: String?
        var minDistance: Float = Float.infinity
        
        for profile in profiles {
            let distance = calculateDistance(between: currentLandmarks, and: profile.landmarks)
            if distance < minDistance {
                minDistance = distance
                bestMatch = profile.character
            }
        }
        
        // Threshold for a valid match (Euclidean distance sum)
        let threshold: Float = 5.0 
        return minDistance < threshold ? bestMatch : nil
    }
    
    private func extractLandmarks(from observation: VNHumanHandPoseObservation) -> [HandLandmark] {
        guard let points = try? observation.recognizedPoints(.all) else { return [] }
        
        return points.compactMap { (joint, point) in
            guard point.confidence > 0.5 else { return nil }
            return HandLandmark(
                x: Float(point.location.x),
                y: Float(point.location.y),
                z: 0, // 2D landmarks for now
                jointName: joint.rawValue.rawValue
            )
        }
    }
    
    private func calculateDistance(between current: [HandLandmark], and profile: [HandLandmark]) -> Float {
        // Simple Euclidean distance sum between corresponding joints
        var totalDistance: Float = 0
        var matchCount = 0
        
        for currentLandmark in current {
            if let profileLandmark = profile.first(where: { $0.jointName == currentLandmark.jointName }) {
                let dx = currentLandmark.x - profileLandmark.x
                let dy = currentLandmark.y - profileLandmark.y
                totalDistance += sqrt(dx * dx + dy * dy)
                matchCount += 1
            }
        }
        
        return matchCount > 0 ? totalDistance / Float(matchCount) : Float.infinity
    }
}
