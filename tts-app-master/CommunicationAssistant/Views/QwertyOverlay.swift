import SwiftUI

/// Overlay that renders the virtual QWERTY keyboard grid on the camera feed
struct QwertyOverlay: View {
    @ObservedObject var keyboardMapper: KeyboardMapper
    var activeKey: String?
    var fingerPositions: [CGPoint]

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                guard keyboardMapper.isCalibrated else { return }

                let keyPositions = keyboardMapper.getKeyPositions()

                for (character, position, hand) in keyPositions {
                    // Convert normalized coordinates to screen coordinates
                    // Vision uses bottom-up, we need to flip Y
                    let x = position.x * size.width
                    let y = (1 - position.y) * size.height

                    let isActive = character == activeKey
                    let keySize: CGFloat = 36
                    let rect = CGRect(
                        x: x - keySize / 2,
                        y: y - keySize / 2,
                        width: keySize,
                        height: keySize
                    )

                    // Draw key background
                    let bgColor: Color = isActive ? .green : (hand == .left ? .blue.opacity(0.3) : .purple.opacity(0.3))
                    let bgPath = RoundedRectangle(cornerRadius: 6)
                        .path(in: rect)
                    context.fill(bgPath, with: .color(bgColor))

                    // Draw key border
                    let borderColor: Color = isActive ? .green : .white.opacity(0.6)
                    context.stroke(bgPath, with: .color(borderColor), lineWidth: isActive ? 3 : 1)

                    // Draw key label
                    let label = character == " " ? "␣" : character
                    let textPoint = CGPoint(x: x, y: y)

                    // Use resolved text for the character
                    let textColor: Color = isActive ? .black : .white
                    context.draw(
                        Text(label)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(textColor),
                        at: textPoint
                    )
                }

                // Draw finger position indicators
                for fingerPos in fingerPositions {
                    let x = fingerPos.x * size.width
                    let y = (1 - fingerPos.y) * size.height

                    let dot = Path(ellipseIn: CGRect(
                        x: x - 8,
                        y: y - 8,
                        width: 16,
                        height: 16
                    ))
                    context.fill(dot, with: .color(.yellow.opacity(0.8)))
                    context.stroke(dot, with: .color(.orange), lineWidth: 2)
                }
            }
        }
    }
}

/// Simplified overlay when calibration is not complete
struct QwertyPlaceholderOverlay: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "keyboard")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.6))

            Text("Keyboard not calibrated")
                .font(.headline)
                .foregroundColor(.white)

            Text("Tap 'Calibrate' to set up air typing")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(24)
        .background(.black.opacity(0.6))
        .cornerRadius(16)
    }
}

/// Compact keyboard status indicator for the chat view
struct KeyboardStatusBar: View {
    let isCalibrated: Bool
    let isActive: Bool
    let lastTypedKey: String?

    var body: some View {
        HStack(spacing: 12) {
            // Calibration status
            HStack(spacing: 4) {
                Circle()
                    .fill(isCalibrated ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                Text(isCalibrated ? "Calibrated" : "Not Calibrated")
                    .font(.caption2)
            }

            Divider()
                .frame(height: 12)

            // Active status
            HStack(spacing: 4) {
                Image(systemName: isActive ? "keyboard.fill" : "keyboard")
                    .font(.caption)
                Text(isActive ? "Air Typing ON" : "Air Typing OFF")
                    .font(.caption2)
            }
            .foregroundColor(isActive ? .green : .secondary)

            // Last typed key
            if let key = lastTypedKey {
                Divider()
                    .frame(height: 12)
                Text("Last: \(key == " " ? "␣" : key)")
                    .font(.caption2.monospaced())
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        // Simulated keyboard layout for preview
        VStack {
            Text("QWERTY Overlay Preview")
                .foregroundColor(.white)
                .padding()

            KeyboardStatusBar(
                isCalibrated: true,
                isActive: true,
                lastTypedKey: "H"
            )
        }
    }
}
