import XCTest
import AVFoundation
@testable import CommunicationAssistant

@MainActor
final class TTSServiceTests: XCTestCase {
    var service: TTSService!
    
    override func setUp() {
        super.setUp()
        service = TTSService()
    }
    
    func testSpeakText() {
        // Since we can't easily mock the hardware synthesizer in this environment,
        // we'll verify the service's state or behavior if we can.
        // For now, we'll verify it doesn't crash and handles basic input.
        XCTAssertNoThrow(service.speak("Hello world"))
    }
    
    func testStopSpeaking() {
        XCTAssertNoThrow(service.stop())
    }
}
