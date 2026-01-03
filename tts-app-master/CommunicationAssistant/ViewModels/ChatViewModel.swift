import Foundation
import SwiftData
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = "" {
        didSet {
            updateSuggestions()
        }
    }
    @Published var suggestedPhrases: [Phrase] = []
    
    private let conversation: Conversation
    private let dataService: DataService
    private let ttsService: TTSService
    private let suggestionEngine = ContextualSuggestionEngine()
    private let placeholderService = PlaceholderService()
    
    let translationService: TranslationService
    let autocompleteService: AutocompleteService
    
    init(conversation: Conversation, dataService: DataService? = nil, ttsService: TTSService? = nil, translationService: TranslationService? = nil, autocompleteService: AutocompleteService? = nil) {
        self.conversation = conversation
        self.dataService = dataService ?? .shared
        self.ttsService = ttsService ?? TTSService()
        self.translationService = translationService ?? TranslationService()
        self.autocompleteService = autocompleteService ?? AutocompleteService()
        self.messages = conversation.messages.sorted(by: { $0.timestamp < $1.timestamp })
        refreshSuggestedPhrases()
    }
    
    func sendMessage() {
        send(text: inputText)
        inputText = ""
    }
    
    private func send(text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let expandedText = placeholderService.expand(text)
        
        // 1. Speak the message
        ttsService.speak(expandedText)
        
        // 2. Save to data service
        dataService.addMessage(to: conversation, text: expandedText, senderType: .user)
        
        do {
            try dataService.save()
            refreshMessages()
        } catch {
            print("Error saving message: \(error)")
        }
    }
    
    func refreshMessages() {
        self.messages = conversation.messages.sorted(by: { $0.timestamp < $1.timestamp })
    }
    
    private func updateSuggestions() {
        let lastWord = inputText.components(separatedBy: .whitespaces).last ?? ""
        autocompleteService.getSuggestions(for: lastWord)
    }
    
    func acceptSuggestion(_ suggestion: String) {
        var words = inputText.components(separatedBy: .whitespaces)
        words.removeLast()
        words.append(suggestion)
        inputText = words.joined(separator: " ") + " "
    }
    
    func selectPhrase(_ phrase: Phrase) {
        dataService.trackPhraseUsage(phrase)
        send(text: phrase.text)
        refreshSuggestedPhrases()
    }
    
    func refreshSuggestedPhrases() {
        do {
            let allPhrases = try dataService.fetchPhrases()
            self.suggestedPhrases = suggestionEngine.getSuggestions(from: allPhrases)
        } catch {
            print("Error fetching phrases for suggestions: \(error)")
        }
    }
    
    func acceptAutocomplete(_ suggestion: String) {
        acceptSuggestion(suggestion)
    }
}