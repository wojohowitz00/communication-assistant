import Foundation
import SwiftUI

@MainActor
class TranslationService: ObservableObject {
    @Published var targetLanguage: Locale.Language?
    @Published var isTranslationEnabled: Bool = false
    
    // In a real implementation with iOS 17.4+ / 18, we would use TranslationSession.
    // For MVP structure, we'll setup the state management.
    // The actual translation execution often happens in the View via .translationTask
    // or by passing a session.
    
    init() {
        // Load saved settings if any
    }
    
    func setTargetLanguage(_ language: Locale.Language) {
        self.targetLanguage = language
        self.isTranslationEnabled = true
    }
    
    func disableTranslation() {
        self.isTranslationEnabled = false
    }
}
