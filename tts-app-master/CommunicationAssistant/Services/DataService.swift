import Foundation
import SwiftData

@MainActor
final class DataService {
    static let shared = DataService()
    
    let container: ModelContainer
    let context: ModelContext
    
    init(container: ModelContainer) {
        self.container = container
        self.context = container.mainContext
    }
    
    private init() {
        let schema = Schema([
            Contact.self,
            Conversation.self,
            Message.self,
            Phrase.self,
            HandProfile.self,
            HandLandmark.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            self.container = container
            self.context = container.mainContext
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    // MARK: - Phrases
    
    func fetchPhrases() throws -> [Phrase] {
        let descriptor = FetchDescriptor<Phrase>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try context.fetch(descriptor)
    }
    
    func addPhrase(text: String, category: String = "General") {
        let phrase = Phrase(text: text, category: category)
        context.insert(phrase)
    }
    
    func deletePhrase(_ phrase: Phrase) {
        context.delete(phrase)
    }
    
    func trackPhraseUsage(_ phrase: Phrase) {
        phrase.usageCount += 1
        phrase.lastUsedAt = Date()
    }
    
    // MARK: - Contacts & Conversations
    
    func fetchContacts() throws -> [Contact] {
        let descriptor = FetchDescriptor<Contact>(sortBy: [SortDescriptor(\.name)])
        return try context.fetch(descriptor)
    }
    
    func addContact(name: String) -> Contact {
        let contact = Contact(name: name)
        context.insert(contact)
        return contact
    }
    
    func addMessage(to conversation: Conversation, text: String, senderType: SenderType, translatedText: String? = nil) {
        let message = Message(text: text, senderType: senderType, translatedText: translatedText, conversation: conversation)
        context.insert(message)
    }
    
    func save() throws {
        try context.save()
    }
}
