import XCTest
import SwiftData
@testable import CommunicationAssistant

@MainActor
final class DataServiceTests: XCTestCase {
    var service: DataService!
    var container: ModelContainer!
    
    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Contact.self, Conversation.self, Message.self, Phrase.self, configurations: config)
        service = DataService(container: container)
    }
    
    func testAddAndFetchPhrase() throws {
        service.addPhrase(text: "Test Phrase", category: "Test")
        try service.save()
        
        let phrases = try service.fetchPhrases()
        XCTAssertEqual(phrases.count, 1)
        XCTAssertEqual(phrases.first?.text, "Test Phrase")
    }
    
    func testAddContactAndMessage() throws {
        let contact = service.addContact(name: "John Doe")
        let conversation = Conversation(contact: contact)
        service.context.insert(conversation) // Conversation needs to be in context
        
        service.addMessage(to: conversation, text: "Hello", senderType: .user)
        try service.save()
        
        XCTAssertEqual(conversation.messages.count, 1)
        XCTAssertEqual(conversation.messages.first?.text, "Hello")
        XCTAssertEqual(contact.conversations.count, 1)
    }
}