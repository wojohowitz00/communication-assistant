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
