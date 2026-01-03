import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Contact.name) private var contacts: [Contact]
    
    @State private var showingAddContact = false
    @State private var newContactName = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(contacts) { contact in
                    NavigationLink {
                        if let conversation = contact.conversations.first {
                            ChatView(viewModel: ChatViewModel(conversation: conversation))
                        } else {
                            // Create a new conversation if none exists
                            let newConv = Conversation(contact: contact)
                            Text("Starting conversation...")
                                .onAppear {
                                    modelContext.insert(newConv)
                                    try? modelContext.save()
                                }
                        }
                    } label: {
                        Text(contact.name)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Contacts")
            .toolbar {
                Button(action: { showingAddContact = true }) {
                    Label("Add Contact", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showingAddContact) {
                NavigationStack {
                    Form {
                        TextField("Name", text: $newContactName)
                    }
                    .navigationTitle("New Contact")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                let contact = Contact(name: newContactName)
                                modelContext.insert(contact)
                                try? modelContext.save()
                                newContactName = ""
                                showingAddContact = false
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingAddContact = false
                            }
                        }
                    }
                }
            }
        }
    }
}