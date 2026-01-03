# Specification: Advanced Phrase Management

## 1. Overview
This track enhances the existing phrase management system to provide faster access and more powerful editing capabilities for non-verbal users. Key improvements include pinned phrases, manual and frequency-based sorting, robust search/filtering, and support for dynamic placeholders (variables).

## 2. Functional Requirements

### 2.1 Quick Access & Organization
- **Pinning:** Users can mark specific phrases as "Pinned." Pinned items appear at the top of the list in a dedicated section or prioritized order.
- **Sorting Modes:** Users can toggle between three explicit sorting modes:
    - **Manual:** Custom order maintained via drag-and-drop.
    - **Alphabetical:** Sorted by phrase text (A-Z).
    - **Frequent:** Sorted by a `usageCount` property, bubbling the most-used phrases to the top.
- **Drag-and-Drop:** In Manual mode, users can reorder phrases within the list.
- **Search & Filter:** 
    - A search bar to filter phrases by text.
    - Filter chips to view phrases by `category`.

### 2.2 Editing & Dynamic Content
- **Simple Placeholders:** Support for basic variables within phrase text:
    - `[Time]`: Automatically replaced with the current time (e.g., "10:30 AM").
    - `[Date]`: Automatically replaced with the current date (e.g., "Dec 22").
    - `[Location]`: Automatically replaced with current city/neighborhood (requires location permissions).
- **Expansion Logic:** Placeholders are expanded to real values immediately before the message is "sent" or spoken by the TTS engine.

### 2.3 Context-Aware Suggestions
- **Contact-Specific Ranking:** Rank phrases higher if they have been frequently used with the current `Contact`.
- **Suggestion Bar:** In the Chat UI, provide a row of 3-5 "Quick Suggestions" based on frequency and context.

## 3. Data Model Updates (SwiftData)
- **Phrase Model:**
    - `isPinned: Bool`
    - `orderIndex: Int`
    - `usageCount: Int`
    - `lastUsedAt: Date?`

## 4. Acceptance Criteria
- [ ] User can pin a phrase and see it at the top of the list.
- [ ] User can toggle sorting between Manual, Alphabetical, and Frequent.
- [ ] User can drag-and-drop a phrase to change its position in Manual mode.
- [ ] Searching for a word correctly filters the visible list.
- [ ] A phrase like "I arrived at [Time]" correctly speaks the current time when tapped.
- [ ] The Chat UI displays context-aware suggestions based on usage frequency.

## 5. Out of Scope
- **Nested Folders:** Organization is limited to categories and pinning.
- **Custom User Variables:** Only system-defined placeholders (`[Time]`, `[Date]`, `[Location]`) are supported.
