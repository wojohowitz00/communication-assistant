# Specification: Core Communication Engine MVP

## 1. Overview
This track focuses on establishing the core functionality of the Communication Assistant app. It includes the foundational SwiftUI architecture, the SwiftData persistence layer for conversations and phrases, the primary Chat Interface, Text-to-Speech (TTS) output, and on-device Translation integration. This serves as the MVP foundation upon which advanced input methods (Gesture/Vision) will be built in subsequent tracks.

## 2. Functional Requirements

### 2.1 Chat Interface (UI)
- **Main View:** A chat-like interface displaying a history of messages in the current session.
- **Input Area:** A standard text input field for typing messages via the software keyboard.
- **Message Bubbles:** Visually distinct bubbles for "Sent" (User) and "Received" (Partner) messages. (Note: Partner input simulated or typed for MVP).
- **TTS Trigger:** Automatically speak the typed text upon sending, with an option to replay.
- **Visual Feedback:** clear indication when TTS is active.

### 2.2 Text-to-Speech (TTS)
- **Engine:** Utilize `AVSpeechSynthesizer` for high-quality voice output.
- **Configuration:** Allow selection of a default system voice.
- **Behavior:** Text entered by the user is immediately synthesized to audio.

### 2.3 Data Persistence (SwiftData)
- **Schema:**
    - `Conversation`: Represents a session or relationship with a `Contact`.
    - `Message`: Individual entries with timestamp, text content, sender type (User/Partner), and translated text (if applicable).
    - `Phrase`: Saved text snippets for quick access.
    - `Contact`: Entity to group conversations (e.g., "Dr. Smith", "Mom").
- **Logging:** All sent and received messages must be persisted to the local database automatically.
- **History View:** A view to list past conversations grouped by Contact and sorted chronologically.

### 2.4 Phrase Management
- **Quick Access UI:** A scrollable list or grid of saved phrases accessible from the Chat Interface.
- **CRUD:** Functionality to Create, Read, Update, and Delete phrases.
- **Ordering:** Ability to pin or reorder favorite phrases (basic implementation).

### 2.5 Translation Integration
- **Framework:** Use Apple's on-device `Translation` framework (iOS 17+).
- **Subtitle Display:** Display the translated text below the original text in the message bubble.
- **Language Selection:** A settings option to select the target language for the current session.

## 3. Non-Functional Requirements
- **Performance:** TTS latency should be under 200ms.
- **Privacy:** All data must be stored locally using SwiftData. No cloud sync.
- **Accessibility:** UI must support Dynamic Type and VoiceOver.
- **Reliability:** Database operations must be atomic and handle potential migration errors gracefully.

## 4. Acceptance Criteria
- [ ] User can type a message, see it in the chat, and hear it spoken aloud.
- [ ] User can save a phrase and quickly tap it to speak/send it.
- [ ] User can create a new "Contact" and start a conversation logged under that contact.
- [ ] User can view a history of past conversations.
- [ ] If translation is enabled, the spoken text is displayed with a subtitle in the selected target language.
- [ ] App persists data across restarts.

## 5. Out of Scope
- **Advanced Input:** Vision-based Hand Gesture Recognition ("Air Typing") and Sign Language Recognition are explicitly excluded from this track and will be addressed in a dedicated follow-up track.
- **Cloud Sync:** No iCloud or backend synchronization.
- **Partner Audio Input:** Speech-to-Text for the communication partner is not required for this MVP (partner inputs via text).
