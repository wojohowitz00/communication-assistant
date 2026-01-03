import SwiftUI
import SwiftData

struct AddPhraseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var text = ""
    @State private var category = "General"
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Phrase", text: $text)
                TextField("Category", text: $category)
            }
            .navigationTitle("New Phrase")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let phrase = Phrase(text: text, category: category)
                        modelContext.insert(phrase)
                        dismiss()
                    }
                    .disabled(text.isEmpty)
                }
            }
        }
    }
}
