import SwiftUI
import SwiftData

enum PhraseSortMode: String, CaseIterable, Identifiable {
    case manual = "Manual"
    case alphabetical = "A-Z"
    case frequent = "Frequent"
    
    var id: String { self.rawValue }
    var icon: String {
        switch self {
        case .manual: return "hand.tap"
        case .alphabetical: return "textformat.abc"
        case .frequent: return "bolt.fill"
        }
    }
}

struct PhraseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var phrases: [Phrase]
    
    @State private var showingAddPhrase = false
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @AppStorage("phraseSortMode") private var sortMode: PhraseSortMode = .manual
    
    var onSelect: (String) -> Void
    
    var filteredPhrases: [Phrase] {
        phrases.filter { phrase in
            let matchesSearch = searchText.isEmpty || phrase.text.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || phrase.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }
    
    var sortedPhrases: [Phrase] {
        switch sortMode {
        case .manual:
            return filteredPhrases.sorted(by: { $0.orderIndex < $1.orderIndex })
        case .alphabetical:
            return filteredPhrases.sorted(by: { $0.text.localizedCaseInsensitiveCompare($1.text) == .orderedAscending })
        case .frequent:
            return filteredPhrases.sorted(by: { 
                if $0.usageCount != $1.usageCount {
                    return $0.usageCount > $1.usageCount
                }
                return $0.lastUsedAt ?? .distantPast > $1.lastUsedAt ?? .distantPast
            })
        }
    }
    
    var pinnedPhrases: [Phrase] {
        sortedPhrases.filter { $0.isPinned }
    }
    
    var otherPhrases: [Phrase] {
        sortedPhrases.filter { !$0.isPinned }
    }
    
    var categories: [String] {
        Array(Set(phrases.map { $0.category })).sorted()
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !categories.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            FilterChip(title: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            
                            ForEach(categories, id: \.self) { category in
                                FilterChip(title: category, isSelected: selectedCategory == category) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 8)
                }
                
                List {
                    if !pinnedPhrases.isEmpty {
                        Section("Pinned") {
                            ForEach(pinnedPhrases) { phrase in
                                phraseRow(for: phrase)
                            }
                            .onMove(perform: sortMode == .manual ? movePinned : nil)
                        }
                    }
                    
                    Section(pinnedPhrases.isEmpty ? "" : "All Phrases") {
                        if otherPhrases.isEmpty && pinnedPhrases.isEmpty {
                            ContentUnavailableView("No Phrases", systemImage: "text.bubble", description: Text("No phrases found matching your criteria."))
                        } else {
                            ForEach(otherPhrases) { phrase in
                                phraseRow(for: phrase)
                            }
                            .onMove(perform: sortMode == .manual ? moveOther : nil)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search phrases")
            .navigationTitle("Saved Phrases")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Menu {
                        Picker("Sort By", selection: $sortMode) {
                            ForEach(PhraseSortMode.allCases) { mode in
                                Label(mode.rawValue, systemImage: mode.icon).tag(mode)
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddPhrase = true }) {
                        Image(systemName: "plus")
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Add new phrase")
                }
            }
            .sheet(isPresented: $showingAddPhrase) {
                AddPhraseView()
            }
        }
    }
    
    private func phraseRow(for phrase: Phrase) -> some View {
        Button(action: {
            onSelect(phrase.text)
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(phrase.text)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(phrase.category)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    togglePin(for: phrase)
                }) {
                    Image(systemName: phrase.isPinned ? "pin.fill" : "pin")
                        .foregroundColor(phrase.isPinned ? .blue : .gray)
                        .padding(8)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                modelContext.delete(phrase)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func togglePin(for phrase: Phrase) {
        withAnimation {
            phrase.isPinned.toggle()
            // Reset order index for manual sorting when pinning/unpinning
            if sortMode == .manual {
                updateManualOrder()
            }
        }
    }
    
    private func movePinned(from source: IndexSet, to destination: Int) {
        var updatedPinned = pinnedPhrases
        updatedPinned.move(fromOffsets: source, toOffset: destination)
        updateIndices(for: updatedPinned + otherPhrases)
    }
    
    private func moveOther(from source: IndexSet, to destination: Int) {
        var updatedOther = otherPhrases
        updatedOther.move(fromOffsets: source, toOffset: destination)
        updateIndices(for: pinnedPhrases + updatedOther)
    }
    
    private func updateManualOrder() {
        updateIndices(for: sortedPhrases)
    }
    
    private func updateIndices(for currentList: [Phrase]) {
        for (index, phrase) in currentList.enumerated() {
            phrase.orderIndex = index
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}
