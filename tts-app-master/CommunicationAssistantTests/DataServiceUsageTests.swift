import XCTest
import SwiftData
@testable import CommunicationAssistant

@MainActor
final class DataServiceUsageTests: XCTestCase {
    var service: DataService!
    var container: ModelContainer!
    
    override func setUp() {
        super.setUp()
        let schema = Schema([Phrase.self, Contact.self, Conversation.self, Message.self, HandProfile.self, HandLandmark.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: [config])
        service = DataService(container: container)
    }
    
    func testTrackPhraseUsage() {
        service.addPhrase(text: "Test Usage")
        let phrase = try! service.fetchPhrases().first!
        
        XCTAssertEqual(phrase.usageCount, 0)
        XCTAssertNil(phrase.lastUsedAt)
        
        service.trackPhraseUsage(phrase)
        
        XCTAssertEqual(phrase.usageCount, 1)
        XCTAssertNotNil(phrase.lastUsedAt)
    }
}
