import SwiftUI
import SwiftData
import AVFoundation

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var handProfiles: [HandProfile]
    
    @StateObject var viewModel: ChatViewModel
    @StateObject private var cameraManager = CameraManager()
    @StateObject private var visionService = VisionService()
    
    @State private var showingPhrases = false
    @State private var showingSettings = false
    @State private var showingTraining = false
    
    #if os(iOS)
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    #endif
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.messages) { message in
                            MessageBubbleView(
                                message: message.text,
                                senderType: message.senderTypeRaw,
                                translatedText: message.translatedText
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.top)
                }
                .onChange(of: viewModel.messages) { oldValue, newValue in
                    if let lastMessage = newValue.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Phrase Suggestions
            if !viewModel.suggestedPhrases.isEmpty && viewModel.inputText.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.suggestedPhrases) { phrase in
                            Button(action: {
                                viewModel.selectPhrase(phrase)
                            }) {
                                Text(phrase.text)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.green.opacity(0.1))
                                    .foregroundColor(.green)
                                    .cornerRadius(16)
                                    .font(.subheadline)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                #if os(iOS)
                .background(Color(.systemGray6).opacity(0.3))
                #else
                .background(Color.gray.opacity(0.05))
                #endif
            }
            
            // Autocomplete suggestions
            if !viewModel.autocompleteService.suggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.autocompleteService.suggestions, id: \.self) { suggestion in
                            Button(action: {
                                viewModel.acceptSuggestion(suggestion)
                            }) {
                                Text(suggestion)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(16)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                #if os(iOS)
                .background(Color(.systemGray6).opacity(0.5))
                #else
                .background(Color.gray.opacity(0.1))
                #endif
            }
            
            Divider()
            
            // Camera Status & Controls
            HStack {
                if visionService.isTypingActive {
                    Label("Air Typing Active", systemImage: "hand.wave.fill")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
                Spacer()
                Button("Calibrate") {
                    showingTraining = true
                }
                .font(.caption)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            HStack(alignment: .bottom, spacing: 12) {
                Button(action: { showingPhrases = true }) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
                .accessibilityLabel("Open Saved Phrases")
                
                TextField("Type your message...", text: $viewModel.inputText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...5)
                    .font(.body)
                    .frame(minHeight: 44)
                
                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .frame(width: 44, height: 44)
                        .background(viewModel.inputText.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .disabled(viewModel.inputText.isEmpty)
                .accessibilityLabel("Send message")
            }
            .padding()
            #if os(iOS)
            .background(Color(.systemBackground))
            #else
            .background(Color(NSColor.windowBackgroundColor))
            #endif
        }
        .navigationTitle("Chat")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Settings")
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $showingPhrases) {
            PhraseListView { selectedText in
                viewModel.inputText = selectedText
                viewModel.sendMessage()
                showingPhrases = false
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(translationService: viewModel.translationService)
        }
        .sheet(isPresented: $showingTraining) {
            TrainingView(cameraManager: cameraManager, visionService: visionService)
        }
        .onAppear {
            let service = visionService
            cameraManager.start()
            service.start()
            cameraManager.onFrameCaptured = { buffer in
                service.process(sampleBuffer: buffer)
            }
            
            service.onCharacterTyped = { character in
                #if os(iOS)
                feedbackGenerator.impactOccurred()
                #endif
                AudioServicesPlaySystemSound(1104) // Tink sound
                
                Task { @MainActor in
                    if character == "BACKSPACE" {
                        if !viewModel.inputText.isEmpty {
                            viewModel.inputText.removeLast()
                        }
                    } else {
                        viewModel.inputText += character
                    }
                }
            }
            
            viewModel.refreshSuggestedPhrases()
        }
        .onDisappear {
            cameraManager.stop()
            visionService.stop()
        }
        .onChange(of: handProfiles) { oldValue, newValue in
            visionService.updateProfiles(newValue)
        }
    }
}