import Foundation
import SwiftData

@Model
final class Contact {
    @Attribute(.unique) var id: UUID
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \Conversation.contact)
    var conversations: [Conversation] = []
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

@Model
final class Conversation {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var contact: Contact?
    
    @Relationship(deleteRule: .cascade, inverse: \Message.conversation)
    var messages: [Message] = []
    
    init(id: UUID = UUID(), createdAt: Date = Date(), contact: Contact? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.contact = contact
    }
}

@Model
final class Message {
    @Attribute(.unique) var id: UUID
    var text: String
    var timestamp: Date
    var senderTypeRaw: String
    var translatedText: String?
    var conversation: Conversation?
    
    var senderType: SenderType {
        get { SenderType(rawValue: senderTypeRaw) ?? .user }
        set { senderTypeRaw = newValue.rawValue }
    }
    
    init(id: UUID = UUID(), text: String, timestamp: Date = Date(), senderType: SenderType, translatedText: String? = nil, conversation: Conversation? = nil) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
        self.senderTypeRaw = senderType.rawValue
        self.translatedText = translatedText
        self.conversation = conversation
    }
}

enum SenderType: String, Codable {
    case user
    case partner
}

@Model
final class Phrase {
    @Attribute(.unique) var id: UUID
    var text: String
    var category: String
    var createdAt: Date
    var isPinned: Bool
    var orderIndex: Int
    var usageCount: Int
    var lastUsedAt: Date?
    
    init(id: UUID = UUID(), text: String, category: String = "General", createdAt: Date = Date(), isPinned: Bool = false, orderIndex: Int = 0, usageCount: Int = 0, lastUsedAt: Date? = nil) {
        self.id = id
        self.text = text
        self.category = category
        self.createdAt = createdAt
        self.isPinned = isPinned
        self.orderIndex = orderIndex
        self.usageCount = usageCount
        self.lastUsedAt = lastUsedAt
    }
}

@Model
final class HandProfile {
    @Attribute(.unique) var id: UUID
    var character: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var landmarks: [HandLandmark] = []
    
    init(id: UUID = UUID(), character: String, landmarks: [HandLandmark] = [], createdAt: Date = Date()) {
        self.id = id
        self.character = character
        self.landmarks = landmarks
        self.createdAt = createdAt
    }
}

@Model
final class HandLandmark {
    @Attribute(.unique) var id: UUID
    var x: Float
    var y: Float
    var z: Float
    var jointName: String?

    init(id: UUID = UUID(), x: Float, y: Float, z: Float = 0, jointName: String? = nil) {
        self.id = id
        self.x = x
        self.y = y
        self.z = z
        self.jointName = jointName
    }
}

// MARK: - Keyboard Calibration

@Model
final class KeyboardCalibration {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var isActive: Bool

    // Left hand home row positions (stored as JSON-encoded data)
    var leftIndexX: Float
    var leftIndexY: Float
    var leftMiddleX: Float
    var leftMiddleY: Float
    var leftRingX: Float
    var leftRingY: Float
    var leftPinkyX: Float
    var leftPinkyY: Float

    // Right hand home row positions
    var rightIndexX: Float
    var rightIndexY: Float
    var rightMiddleX: Float
    var rightMiddleY: Float
    var rightRingX: Float
    var rightRingY: Float
    var rightPinkyX: Float
    var rightPinkyY: Float

    // Calculated spacing
    var keyWidth: Float
    var rowHeight: Float

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        isActive: Bool = true,
        leftIndex: CGPoint = .zero,
        leftMiddle: CGPoint = .zero,
        leftRing: CGPoint = .zero,
        leftPinky: CGPoint = .zero,
        rightIndex: CGPoint = .zero,
        rightMiddle: CGPoint = .zero,
        rightRing: CGPoint = .zero,
        rightPinky: CGPoint = .zero,
        keyWidth: Float = 0.05,
        rowHeight: Float = 0.06
    ) {
        self.id = id
        self.createdAt = createdAt
        self.isActive = isActive
        self.leftIndexX = Float(leftIndex.x)
        self.leftIndexY = Float(leftIndex.y)
        self.leftMiddleX = Float(leftMiddle.x)
        self.leftMiddleY = Float(leftMiddle.y)
        self.leftRingX = Float(leftRing.x)
        self.leftRingY = Float(leftRing.y)
        self.leftPinkyX = Float(leftPinky.x)
        self.leftPinkyY = Float(leftPinky.y)
        self.rightIndexX = Float(rightIndex.x)
        self.rightIndexY = Float(rightIndex.y)
        self.rightMiddleX = Float(rightMiddle.x)
        self.rightMiddleY = Float(rightMiddle.y)
        self.rightRingX = Float(rightRing.x)
        self.rightRingY = Float(rightRing.y)
        self.rightPinkyX = Float(rightPinky.x)
        self.rightPinkyY = Float(rightPinky.y)
        self.keyWidth = keyWidth
        self.rowHeight = rowHeight
    }

    // Convenience accessors
    var leftIndex: CGPoint { CGPoint(x: CGFloat(leftIndexX), y: CGFloat(leftIndexY)) }
    var leftMiddle: CGPoint { CGPoint(x: CGFloat(leftMiddleX), y: CGFloat(leftMiddleY)) }
    var leftRing: CGPoint { CGPoint(x: CGFloat(leftRingX), y: CGFloat(leftRingY)) }
    var leftPinky: CGPoint { CGPoint(x: CGFloat(leftPinkyX), y: CGFloat(leftPinkyY)) }
    var rightIndex: CGPoint { CGPoint(x: CGFloat(rightIndexX), y: CGFloat(rightIndexY)) }
    var rightMiddle: CGPoint { CGPoint(x: CGFloat(rightMiddleX), y: CGFloat(rightMiddleY)) }
    var rightRing: CGPoint { CGPoint(x: CGFloat(rightRingX), y: CGFloat(rightRingY)) }
    var rightPinky: CGPoint { CGPoint(x: CGFloat(rightPinkyX), y: CGFloat(rightPinkyY)) }
}
