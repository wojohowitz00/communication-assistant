# Tech Stack - Communication Assistant

## Frontend & Application Logic
- **Primary Language:** Swift
- **UI Framework:** SwiftUI for a modern, declarative, and accessible interface.
- **Minimum iOS Version:** iOS 17.0+ (to leverage the latest SwiftData and Vision enhancements).

## AI & Machine Learning
- **Vision Framework:** For real-time hand-pose detection and tracking to support "typing in the air."
- **Core ML:** For executing custom-trained models for standard sign language recognition and gesture-to-text conversion.
- **AVFoundation:** For low-latency camera access and high-quality Text-to-Speech (TTS) using AVSpeechSynthesizer.

## Data & Persistence
- **Storage:** SwiftData for local, encrypted storage of conversation logs, customizable phrases, and user profiles.
- **Encryption:** Leveraging iOS's built-in Data Protection API for at-rest encryption of the local database.

## External Services (Optional/Limited)
- **On-Device Translation:** Utilizing Apple's `Translation` framework (available in iOS 17+) for privacy-preserving, on-device translation.
