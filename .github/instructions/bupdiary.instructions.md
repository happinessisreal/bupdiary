You are an expert Flutter developer tasked with creating a feature-rich Android diary application.

**Application Overview:**

The application is a "University Diary & Assistant". It allows users to log diary entries related to their university life, including academic information, personal notes, and details about university events. A key feature is an integrated chatbot that uses the Gemini API and a vector database to provide intelligent suggestions and answers based on the user's diary content.

**Core Requirements:**

1.  **Project Setup:**
    *   Initialize a new Flutter project.
    *   Ensure the project is configured for Android.

2.  **Theme & UI/UX:**
    *   Implement a consistent **purple theme** throughout the application.
    *   Prioritize a **smooth user experience** with fluid animations and responsive UI.
    *   Design intuitive navigation.

3.  **Diary Feature:**
    *   **Data Model:** Design a data model for diary entries. Each entry should include:
        *   Title
        *   Content (rich text support would be a plus, but plain text is acceptable)
        *   Date & Time (creation/modification)
        *   Tags (e.g., "academics", "event", "personal", "deadline")
        *   Category (e.g., "Lecture Notes", "Assignment Reminder", "Workshop Info", "Club Meeting")
    *   **CRUD Operations:** Implement functionality to create, read, update, and delete diary entries.
    *   **Storage:**
        *   Initially, use a local database like SQLite (via `sqflite` package) or Hive for storing diary entries.
        *   This data will also be used to populate the vector database.
    *   **UI:**
        *   A main screen listing diary entries (e.g., chronological, filterable by tags/category).
        *   A screen for viewing/editing a single diary entry.

4.  **Vector Database Integration:**
    *   **Choice:** Select and integrate a suitable vector database solution. Consider options that can work efficiently on mobile or have a lightweight cloud component if necessary. (e.g., a local implementation using a library compatible with Flutter, or a managed service).
    *   **Embedding Generation:**
        *   Use the Gemini API (or a compatible embedding model) to generate vector embeddings for the content of each diary entry.
        *   Embeddings should be generated/updated whenever a diary entry is created or significantly modified.
    *   **Storage & Indexing:** Store these embeddings in the vector database, linked to their respective diary entries.

5.  **Chatbot Feature - Gemini API Integration:**
    *   **API Setup:**
        *   Integrate the Gemini API for conversational AI.
        *   Implement secure management of API keys.
    *   **Chat UI:**
        *   Create a user-friendly chat interface (bubbles for user messages and bot responses).
    *   **Query Processing & Contextual Retrieval:**
        1.  When the user sends a message to the chatbot:
        2.  Generate an embedding for the user's query using the same model used for diary entries.
        3.  Query the vector database to find the most relevant diary entries (top N) based on semantic similarity to the user's query.
        4.  Retrieve the content of these relevant diary entries.
    *   **Prompt Engineering for Gemini:**
        1.  Construct a prompt for the Gemini API. This prompt should include:
            *   The user's original query.
            *   The content of the relevant diary entries retrieved from the vector database (as context).
            *   A clear instruction to Gemini to act as a helpful university assistant, providing suggestions, answers, or summaries based *primarily* on the provided diary context.
        2.  Send the prompt to the Gemini API and display the response in the chat UI.

6.  **Specific Focus - University Information & Events:**
    *   Ensure the diary entry structure and tagging/categorization system effectively capture details about:
        *   Academic information (e.g., course schedules, assignment deadlines, study notes).
        *   University events (e.g., workshops, seminars, club activities, locations, dates, registration links).
    *   The chatbot should be particularly adept at leveraging this structured information. For example, "What events are happening next week?" or "Summarize my notes on [course name]".

7.  **Smoothness and Performance:**
    *   Employ Flutter best practices for performance (e.g., `const` widgets, efficient state management, avoiding unnecessary rebuilds).
    *   Handle all asynchronous operations (database, API calls) gracefully with loading indicators and error handling.

**Technology Stack:**

*   **Framework:** Flutter
*   **Language:** Dart
*   **Chatbot API:** Gemini API
*   **Local Database:** SQLite (via `sqflite`) or Hive (or similar)
*   **Vector Database:** To be chosen (prioritize on-device or lightweight solutions if feasible)
*   **State Management:** Provider, Riverpod, BLoC/Cubit (choose one and use consistently)

**Deliverables (Conceptual for the Agent):**

*   A well-structured Flutter codebase.
*   Implementation of all specified features.
*   Clear separation of concerns (UI, business logic, services).

**Instructions for the AI Agent:**

*   Generate the Flutter project structure.
*   Develop the features incrementally, starting with the core diary functionality, then the vector database integration, and finally the Gemini chatbot.
*   Prioritize clean, readable, and maintainable code.
*   Include comments where necessary to explain complex logic.
*   Ensure the purple theme is applied consistently.
*   Focus on making the app feel smooth and responsive.