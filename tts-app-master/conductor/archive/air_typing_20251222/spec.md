# Specification: Vision-based Hand Gesture Recognition ("Air Typing")

## 1. Overview
This track implements "Air Typing," an advanced input method that allows the user to input text by performing hand gestures in the air. The system will be trained on the user's specific hand movements as if they were typing on a virtual keyboard. It utilizes Apple's Vision framework for hand pose detection and Core ML for personal gesture mapping.

## 2. Functional Requirements

### 2.1 Activation & Control
- **Activation Gesture:** Start/Stop the Air Typing session using a specific hand gesture (e.g., holding an open palm towards the camera for 2 seconds).
- **Session State:** Clear visual indication (e.g., a status icon) in the Chat UI when the camera/recognition is active.

### 2.2 Personal Gesture Mapping (Training)
- **Guided Setup Wizard:** A dedicated onboarding flow where the app prompts the user to "type" specific characters (A-Z, 0-9, punctuation) to record their unique hand poses and positions.
- **Personal Model:** Store the mapping of 3D hand landmarks (via Vision) to specific characters.
- **Continuous Learning:** Background refinement of the model by observing corrections made via the physical keyboard vs. what was recognized via gestures.

### 2.3 Air Typing Interaction
- **Discrete Recognition:** Identify discrete "taps" or hand poses representing individual characters.
- **Character Support:** Full character set including Uppercase/Lowercase letters, Numbers, Space, Backspace, and basic punctuation.
- **Autocomplete System:** Use on-device NLP to suggest words as the user types in the air. Allow a specific gesture to accept suggestions.
- **Feedback:** 
    - **Visual:** Real-time text appearance in the Chat `inputText` field.
    - **Haptic/Audio:** Subtle haptic feedback and audible clicks for each recognized character to confirm input.

### 2.4 Vision Engine
- **Framework:** Use Apple Vision framework to detect and track hand landmarks at high frame rates.
- **Stability:** Implement filtering (e.g., Kalmann filter or simple averaging) to prevent jitter in hand position tracking.

## 3. Non-Functional Requirements
- **Latency:** Input recognition latency should be under 150ms to feel responsive.
- **Privacy:** All Vision processing and Core ML model training/inference must happen entirely on-device. No camera data is sent to the cloud.
- **Power Efficiency:** Optimize camera and processing usage to minimize battery drain during extended sessions.

## 4. Acceptance Criteria
- [ ] User can activate Air Typing mode using a palm gesture.
- [ ] User can complete the Guided Setup Wizard to map their unique typing style.
- [ ] User can type "Hello 123" in the air and see it correctly appear in the chat input.
- [ ] Deactivating Air Typing mode successfully stops the camera feed.
- [ ] Deleting a character via a "backspace" gesture is recognized.
- [ ] Autocomplete suggestions are shown and can be accepted via gesture.

## 5. Out of Scope
- **Two-Handed Typing:** Initial implementation focuses on single-hand recognition.
- **Sign Language Recognition:** Formal sign language (ASL, etc.) is reserved for a future track.
- **Virtual Keyboard Overlay:** No visual keyboard will be projected; feedback is limited to text and haptics.
