import XCTest
import Vision
@testable import CommunicationAssistant

@MainActor
final class VisionServiceTests: XCTestCase {
    var visionService: VisionService!
    
    override func setUp() {
        super.setUp()
        visionService = VisionService()
    }
    
    func testInitialState() {
        XCTAssertFalse(visionService.isProcessing)
    }
    
    func testStartProcessing() {
        visionService.start()
        XCTAssertTrue(visionService.isProcessing)
    }
    
    func testStopProcessing() {
        visionService.start()
        visionService.stop()
        XCTAssertFalse(visionService.isProcessing)
    }
}
