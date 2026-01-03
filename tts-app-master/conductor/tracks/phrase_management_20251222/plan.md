# Implementation Plan - Advanced Phrase Management

## Phase 1: Data Model & Expansion Logic [checkpoint: 6bfdbe8]
- [x] Task: Update Phrase Model d3b24bf
- [x] Task: Implement Placeholder Service 5792395
- [x] Task: Update DataService for Usage Tracking 6f70ea4
- [x] Task: Conductor - User Manual Verification 'Data Model & Expansion Logic' (Protocol in workflow.md) 6bfdbe8

## Phase 2: Organization, Search & Filter [checkpoint: a1d5425]
- [x] Task: Implement Search & Category Filtering 4e3092a
- [x] Task: Implement Pinning Logic 32dd59e
- [x] Task: Conductor - User Manual Verification 'Organization, Search & Filter' (Protocol in workflow.md) a1d5425

## Phase 3: Sorting Modes & Manual Reordering [checkpoint: 55a9258]
- [x] Task: Implement Sorting Mode Selector 1a9a6ed
- [x] Task: Implement Manual Reordering 1a9a6ed
- [x] Task: Conductor - User Manual Verification 'Sorting Modes & Manual Reordering' (Protocol in workflow.md) 55a9258

## Phase 4: Contextual Suggestions in Chat
- [x] Task: Build Contextual Suggestion Engine a6fe7a0
  - Logic to rank phrases based on `usageCount` and proximity to current `Contact`.
  - Add unit tests for ranking logic.
- [x] Task: Integrate Suggestion Bar into ChatView cef0178
  - Display top 3 suggestions above the input field.
  - Tapping a suggestion expands placeholders and sends the message.
- [ ] Task: Conductor - User Manual Verification 'Contextual Suggestions in Chat' (Protocol in workflow.md)

## Phase 5: Final integration & Polish
- [ ] Task: Location Support for [Location] Placeholder
  - Integrate `CLLocationManager` (request permissions, handle auth).
- [ ] Task: Polish UI & Accessibility
  - Ensure high contrast and large touch targets for new controls.
- [ ] Task: Conductor - User Manual Verification 'Final integration & Polish' (Protocol in workflow.md)
