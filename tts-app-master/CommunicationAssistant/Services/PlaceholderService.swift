import Foundation

final class PlaceholderService {
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    func expand(_ text: String) -> String {
        var expandedText = text
        
        if expandedText.contains("[Time]") {
            expandedText = expandedText.replacingOccurrences(of: "[Time]", with: timeFormatter.string(from: Date()))
        }
        
        if expandedText.contains("[Date]") {
            expandedText = expandedText.replacingOccurrences(of: "[Date]", with: dateFormatter.string(from: Date()))
        }
        
        // Placeholder for Location (implemented in Phase 5)
        if expandedText.contains("[Location]") {
            expandedText = expandedText.replacingOccurrences(of: "[Location]", with: "Current Location")
        }
        
        return expandedText
    }
}
