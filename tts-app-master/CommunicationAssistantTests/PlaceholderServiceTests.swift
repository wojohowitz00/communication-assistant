import XCTest
@testable import CommunicationAssistant

final class PlaceholderServiceTests: XCTestCase {
    var service: PlaceholderService!
    
    override func setUp() {
        super.setUp()
        service = PlaceholderService()
    }
    
    func testExpandTime() {
        let input = "I am at home at [Time]"
        let output = service.expand(input)
        
        // Output should not contain [Time]
        XCTAssertFalse(output.contains("[Time]"))
        // Check if it matches a basic time format (simplified)
        let regex = try! NSRegularExpression(pattern: #"\d{1,2}:\d{2}"#)
        let range = NSRange(location: 0, length: output.utf16.count)
        XCTAssertNotNil(regex.firstMatch(in: output, range: range))
    }
    
    func testExpandDate() {
        let input = "Today is [Date]"
        let output = service.expand(input)
        
        XCTAssertFalse(output.contains("[Date]"))
    }
    
    func testExpandMultiple() {
        let input = "It is [Time] on [Date]"
        let output = service.expand(input)
        
        XCTAssertFalse(output.contains("[Time]"))
        XCTAssertFalse(output.contains("[Date]"))
    }
}
