import Foundation
import Vision

/// Maps finger positions to QWERTY keyboard keys using calibrated home row reference
@MainActor
final class KeyboardMapper: ObservableObject {

    // MARK: - Types

    enum HandSide: String, Codable {
        case left, right
    }

    enum Finger: String, CaseIterable, Codable {
        case index, middle, ring, pinky

        var visionJoint: VNHumanHandPoseObservation.JointName {
            switch self {
            case .index: return .indexTip
            case .middle: return .middleTip
            case .ring: return .ringTip
            case .pinky: return .littleTip
            }
        }
    }

    struct KeyDefinition {
        let character: String
        let hand: HandSide
        let finger: Finger
        let rowOffset: CGFloat    // Relative to home row (0 = home, positive = up)
        let columnOffset: CGFloat // Relative to home position (0 = home, positive = right)
    }

    // MARK: - Published State

    @Published private(set) var isCalibrated = false
    @Published private(set) var calibrationDate: Date?

    // MARK: - Calibration Data

    private var leftHomeRow: [Finger: CGPoint] = [:]
    private var rightHomeRow: [Finger: CGPoint] = [:]
    private var keyWidth: CGFloat = 0.05  // Default key spacing in normalized coords
    private var rowHeight: CGFloat = 0.06 // Default row height in normalized coords

    // MARK: - QWERTY Layout

    /// Standard QWERTY layout with finger assignments and position offsets
    /// Offsets are relative to home row position for each finger
    private let qwertyLayout: [KeyDefinition] = [
        // Top row (numbers row skipped for MVP)
        // QWERTY row (row offset +1 from home)
        KeyDefinition(character: "Q", hand: .left, finger: .pinky, rowOffset: 1, columnOffset: -0.5),
        KeyDefinition(character: "W", hand: .left, finger: .ring, rowOffset: 1, columnOffset: -0.5),
        KeyDefinition(character: "E", hand: .left, finger: .middle, rowOffset: 1, columnOffset: -0.5),
        KeyDefinition(character: "R", hand: .left, finger: .index, rowOffset: 1, columnOffset: -0.5),
        KeyDefinition(character: "T", hand: .left, finger: .index, rowOffset: 1, columnOffset: 0.5),
        KeyDefinition(character: "Y", hand: .right, finger: .index, rowOffset: 1, columnOffset: -0.5),
        KeyDefinition(character: "U", hand: .right, finger: .index, rowOffset: 1, columnOffset: 0.5),
        KeyDefinition(character: "I", hand: .right, finger: .middle, rowOffset: 1, columnOffset: 0.5),
        KeyDefinition(character: "O", hand: .right, finger: .ring, rowOffset: 1, columnOffset: 0.5),
        KeyDefinition(character: "P", hand: .right, finger: .pinky, rowOffset: 1, columnOffset: 0.5),

        // Home row (row offset 0)
        KeyDefinition(character: "A", hand: .left, finger: .pinky, rowOffset: 0, columnOffset: 0),
        KeyDefinition(character: "S", hand: .left, finger: .ring, rowOffset: 0, columnOffset: 0),
        KeyDefinition(character: "D", hand: .left, finger: .middle, rowOffset: 0, columnOffset: 0),
        KeyDefinition(character: "F", hand: .left, finger: .index, rowOffset: 0, columnOffset: 0),
        KeyDefinition(character: "G", hand: .left, finger: .index, rowOffset: 0, columnOffset: 1),
        KeyDefinition(character: "H", hand: .right, finger: .index, rowOffset: 0, columnOffset: -1),
        KeyDefinition(character: "J", hand: .right, finger: .index, rowOffset: 0, columnOffset: 0),
        KeyDefinition(character: "K", hand: .right, finger: .middle, rowOffset: 0, columnOffset: 0),
        KeyDefinition(character: "L", hand: .right, finger: .ring, rowOffset: 0, columnOffset: 0),

        // Bottom row (row offset -1 from home)
        KeyDefinition(character: "Z", hand: .left, finger: .pinky, rowOffset: -1, columnOffset: 0.5),
        KeyDefinition(character: "X", hand: .left, finger: .ring, rowOffset: -1, columnOffset: 0.5),
        KeyDefinition(character: "C", hand: .left, finger: .middle, rowOffset: -1, columnOffset: 0.5),
        KeyDefinition(character: "V", hand: .left, finger: .index, rowOffset: -1, columnOffset: 0.5),
        KeyDefinition(character: "B", hand: .left, finger: .index, rowOffset: -1, columnOffset: 1.5),
        KeyDefinition(character: "N", hand: .right, finger: .index, rowOffset: -1, columnOffset: -0.5),
        KeyDefinition(character: "M", hand: .right, finger: .index, rowOffset: -1, columnOffset: 0.5),

        // Space bar (bottom row, any index finger)
        KeyDefinition(character: " ", hand: .left, finger: .index, rowOffset: -2, columnOffset: 0),
        KeyDefinition(character: " ", hand: .right, finger: .index, rowOffset: -2, columnOffset: 0),
    ]

    // Backspace is detected by pinky movement up-right
    private let backspaceKey = KeyDefinition(
        character: "BACKSPACE",
        hand: .right,
        finger: .pinky,
        rowOffset: 1,
        columnOffset: 1
    )

    // MARK: - Calibration

    /// Calibrates the keyboard using the current hand positions as home row reference
    /// - Parameters:
    ///   - leftObservation: Left hand pose observation
    ///   - rightObservation: Right hand pose observation
    /// - Returns: True if calibration succeeded
    func calibrate(
        leftObservation: VNHumanHandPoseObservation,
        rightObservation: VNHumanHandPoseObservation
    ) -> Bool {
        // Extract fingertip positions for both hands
        guard let leftPositions = extractFingerPositions(from: leftObservation),
              let rightPositions = extractFingerPositions(from: rightObservation) else {
            return false
        }

        // Store home row positions
        leftHomeRow = leftPositions
        rightHomeRow = rightPositions

        // Calculate key spacing from index finger distance (F to J)
        if let leftIndex = leftPositions[.index], let rightIndex = rightPositions[.index] {
            let fingerDistance = distance(leftIndex, rightIndex)
            // F to J spans approximately 4 key widths (F-G-H-J)
            keyWidth = fingerDistance / 4.0
            rowHeight = keyWidth * 1.2 // Rows are slightly taller than wide
        }

        isCalibrated = true
        calibrationDate = Date()

        return true
    }

    /// Resets calibration data
    func reset() {
        leftHomeRow = [:]
        rightHomeRow = [:]
        isCalibrated = false
        calibrationDate = nil
        keyWidth = 0.05
        rowHeight = 0.06
    }

    // MARK: - Key Mapping

    /// Maps a finger tap to the nearest keyboard key
    /// - Parameters:
    ///   - observation: Current hand pose observation
    ///   - finger: Which finger tapped
    ///   - hand: Which hand (left or right)
    /// - Returns: The character for the key, or nil if no match
    func getKey(
        observation: VNHumanHandPoseObservation,
        finger: Finger,
        hand: HandSide
    ) -> String? {
        guard isCalibrated else { return nil }

        // Get current finger position
        guard let currentPos = getFingerPosition(observation: observation, finger: finger) else {
            return nil
        }

        // Get home row position for this finger
        let homeRow = hand == .left ? leftHomeRow : rightHomeRow
        guard let homePos = homeRow[finger] else { return nil }

        // Calculate offset from home position
        let offset = CGPoint(
            x: currentPos.x - homePos.x,
            y: currentPos.y - homePos.y
        )

        // Convert offset to row/column units
        let columnUnits = offset.x / keyWidth
        let rowUnits = offset.y / rowHeight

        // Find nearest key for this finger on this hand
        return findNearestKey(
            hand: hand,
            finger: finger,
            columnOffset: columnUnits,
            rowOffset: rowUnits
        )
    }

    /// Simplified version: maps finger position to key for any detected finger
    func getKey(
        observation: VNHumanHandPoseObservation,
        hand: HandSide
    ) -> String? {
        guard isCalibrated else { return nil }

        // Try each finger and find the one with the most confident tap
        for finger in Finger.allCases {
            if let key = getKey(observation: observation, finger: finger, hand: hand) {
                return key
            }
        }
        return nil
    }

    // MARK: - Private Helpers

    private func extractFingerPositions(
        from observation: VNHumanHandPoseObservation
    ) -> [Finger: CGPoint]? {
        var positions: [Finger: CGPoint] = [:]

        for finger in Finger.allCases {
            guard let point = try? observation.recognizedPoint(finger.visionJoint),
                  point.confidence > 0.5 else {
                return nil // Require all fingers visible
            }
            positions[finger] = point.location
        }

        return positions
    }

    private func getFingerPosition(
        observation: VNHumanHandPoseObservation,
        finger: Finger
    ) -> CGPoint? {
        guard let point = try? observation.recognizedPoint(finger.visionJoint),
              point.confidence > 0.5 else {
            return nil
        }
        return point.location
    }

    private func findNearestKey(
        hand: HandSide,
        finger: Finger,
        columnOffset: CGFloat,
        rowOffset: CGFloat
    ) -> String? {
        // Check backspace first (right pinky, up-right position)
        if hand == .right && finger == .pinky &&
           rowOffset > 0.5 && columnOffset > 0.3 {
            return "BACKSPACE"
        }

        // Filter keys for this hand and finger
        let candidateKeys = qwertyLayout.filter { key in
            key.hand == hand && key.finger == finger
        }

        guard !candidateKeys.isEmpty else { return nil }

        // Find nearest key by distance
        var nearestKey: KeyDefinition?
        var minDistance: CGFloat = .infinity

        for key in candidateKeys {
            let dx = columnOffset - key.columnOffset
            let dy = rowOffset - key.rowOffset
            let dist = sqrt(dx * dx + dy * dy)

            if dist < minDistance {
                minDistance = dist
                nearestKey = key
            }
        }

        // Threshold: must be within ~1.5 key widths of a key
        let threshold: CGFloat = 1.5
        if minDistance < threshold {
            return nearestKey?.character
        }

        return nil
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx * dx + dy * dy)
    }

    // MARK: - Overlay Data

    /// Returns key positions in normalized coordinates for overlay rendering
    func getKeyPositions() -> [(character: String, position: CGPoint, hand: HandSide)] {
        guard isCalibrated else { return [] }

        var positions: [(String, CGPoint, HandSide)] = []

        for key in qwertyLayout {
            let homeRow = key.hand == .left ? leftHomeRow : rightHomeRow
            guard let homePos = homeRow[key.finger] else { continue }

            let x = homePos.x + key.columnOffset * keyWidth
            let y = homePos.y + key.rowOffset * rowHeight

            positions.append((key.character, CGPoint(x: x, y: y), key.hand))
        }

        // Add backspace
        if let rightPinkyHome = rightHomeRow[.pinky] {
            let x = rightPinkyHome.x + backspaceKey.columnOffset * keyWidth
            let y = rightPinkyHome.y + backspaceKey.rowOffset * rowHeight
            positions.append(("⌫", CGPoint(x: x, y: y), .right))
        }

        return positions
    }
}
