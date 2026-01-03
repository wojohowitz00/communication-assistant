import XCTest
@testable import CommunicationAssistant

@MainActor
final class SuggestionEngineTests: XCTestCase {
    var engine: ContextualSuggestionEngine!
    
    override func setUp() {
        super.setUp()
        engine = ContextualSuggestionEngine()
    }
    
    func testSuggestionRanking() {
        let p1 = Phrase(text: "Low frequency", usageCount: 1)
        let p2 = Phrase(text: "High frequency", usageCount: 10)
        let p3 = Phrase(text: "Recent usage", usageCount: 1, lastUsedAt: Date())
        
        let suggestions = engine.getSuggestions(from: [p1, p2, p3], limit: 2)
        
        XCTAssertEqual(suggestions.count, 2)
        XCTAssertEqual(suggestions[0].text, "High frequency")
        XCTAssertEqual(suggestions[1].text, "Recent usage")
    }
}
