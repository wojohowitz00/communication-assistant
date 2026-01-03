import XCTest
@testable import CommunicationAssistant

final class PhraseModelTests: XCTestCase {
    func testPhraseInitializationWithNewProperties() {
        let text = "Hello"
        let category = "Greetings"
        let phrase = Phrase(text: text, category: category, isPinned: true, orderIndex: 5)
        
        XCTAssertEqual(phrase.text, text)
        XCTAssertEqual(phrase.category, category)
        XCTAssertTrue(phrase.isPinned)
        XCTAssertEqual(phrase.orderIndex, 5)
        XCTAssertEqual(phrase.usageCount, 0)
        XCTAssertNil(phrase.lastUsedAt)
    }
}
