import XCTest
import Vision
@testable import CommunicationAssistant

final class HandProfileTests: XCTestCase {
    func testHandProfileInitialization() {
        let character = "A"
        let landmark = HandLandmark(x: 0.5, y: 0.5, z: 0.1)
        let profile = HandProfile(character: character, landmarks: [landmark])
        
        XCTAssertEqual(profile.character, character)
        XCTAssertEqual(profile.landmarks.count, 1)
        XCTAssertEqual(profile.landmarks[0].x, 0.5)
    }
}
