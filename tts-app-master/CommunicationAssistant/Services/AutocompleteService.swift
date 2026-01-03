import Foundation
#if os(iOS)
import UIKit
#endif

@MainActor
final class AutocompleteService: ObservableObject {
    @Published var suggestions: [String] = []
    
    #if os(iOS)
    private let textChecker = UITextChecker()
    #endif
    
    func getSuggestions(for text: String) {
        guard !text.isEmpty else {
            self.suggestions = []
            return
        }
        
        #if os(iOS)
        let range = NSRange(location: 0, length: text.utf16.count)
        let completions = textChecker.completions(forPartialWordRange: range, in: text, language: "en_US")
        
        Task { @MainActor in
            self.suggestions = Array(completions?.prefix(3) ?? [])
        }
        #else
        // Mock suggestions for macOS testing
        Task { @MainActor in
            self.suggestions = ["Hello", "Help", "Hear"].filter { $0.lowercased().hasPrefix(text.lowercased()) }
        }
        #endif
    }
}
