import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var translationService: TranslationService
    
    // Sample supported languages for MVP
    let availableLanguages: [Locale.Language] = [
        .init(identifier: "es"), // Spanish
        .init(identifier: "fr"), // French
        .init(identifier: "de"), // German
        .init(identifier: "ja"), // Japanese
        .init(identifier: "zh"), // Chinese
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Translation") {
                    Toggle("Enable Translation", isOn: $translationService.isTranslationEnabled)
                    
                    if translationService.isTranslationEnabled {
                        Picker("Target Language", selection: $translationService.targetLanguage) {
                            Text("Select Language").tag(nil as Locale.Language?)
                            ForEach(availableLanguages, id: \.self) { language in
                                Text(Locale.current.localizedString(forIdentifier: language.maximalIdentifier) ?? language.maximalIdentifier)
                                    .tag(language as Locale.Language?)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
    }
}
