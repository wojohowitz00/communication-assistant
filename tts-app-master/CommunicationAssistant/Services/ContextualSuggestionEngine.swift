import Foundation
import SwiftData

@MainActor
final class ContextualSuggestionEngine {
    func getSuggestions(from phrases: [Phrase], limit: Int = 3) -> [Phrase] {
        // Simple ranking for now: usageCount descending, then lastUsedAt descending
        // Future iteration: add contact-specific ranking
        
        return phrases.sorted(by: {
            if $0.usageCount != $1.usageCount {
                return $0.usageCount > $1.usageCount
            }
            return $0.lastUsedAt ?? .distantPast > $1.lastUsedAt ?? .distantPast
        }).prefix(limit).map { $0 }
    }
}
