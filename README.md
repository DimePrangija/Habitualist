# Habitualist

A habit tracking application for iPhone built with SwiftUI and SwiftData.

## Features

- Create habits with just a title
- Track daily completion with visual status indicators
- Edit habit titles and archive habits
- Local-only persistence (no cloud sync)
- Automatic date handling using device timezone

## Requirements

- iOS 17.0+
- Xcode 15.0+
- iPhone device or simulator

## How to Run

1. Open Xcode (15.0 or later)
2. Create a new project:
   - File → New → Project
   - Select "iOS" → "App"
   - Product Name: `Habitualist`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: `SwiftData` (check the box)
   - Minimum Deployment: `iOS 17.0`
3. Replace the default files with the project files:
   - Delete the default `ContentView.swift` and `HabitualistApp.swift` (if auto-generated)
   - Copy all files from this repository into your Xcode project, maintaining the folder structure:
     - `HabitualistApp.swift` → Root of project
     - `Models/` folder → Add to project
     - `Services/` folder → Add to project
     - `Views/` folder → Add to project
4. Build and run (⌘R) on iPhone 14 simulator or device

## Project Structure

```
Habitualist/
├── HabitualistApp.swift          # App entry point with SwiftData setup
├── Models/
│   ├── Habit.swift               # SwiftData model for habits
│   └── Completion.swift          # SwiftData model for daily completions
├── Services/
│   └── DayKeyService.swift       # Date key helper using device timezone
└── Views/
    ├── TodayView.swift           # Main screen with habit list
    ├── AddHabitView.swift        # Form to add new habits
    ├── EditHabitView.swift       # Form to edit/archive habits
    └── HabitStatusIcon.swift     # Status indicator component
```

## Files Created

1. **HabitualistApp.swift** - Main app entry point, configures SwiftData model container
2. **Models/Habit.swift** - Habit model with id, title, createdAt, isArchived
3. **Models/Completion.swift** - Completion model with habitId, dateKey, completedAt
4. **Services/DayKeyService.swift** - Service for generating YYYY-MM-DD date keys in device timezone
5. **Views/TodayView.swift** - Main view showing today's habits with toggle functionality
6. **Views/AddHabitView.swift** - Modal view for creating new habits
7. **Views/EditHabitView.swift** - Modal view for editing titles and archiving habits
8. **Views/HabitStatusIcon.swift** - Reusable status icon component (green checkmark / red X)

## Architecture

- **Models**: SwiftData `@Model` classes for persistence
- **Services**: Business logic (date handling)
- **Views**: SwiftUI views with clean separation of concerns
- **Data Flow**: SwiftData `@Query` and `@Environment(\.modelContext)` for reactive data

## Testing Checklist

- ✅ Add 3 habits and see them in Today view
- ✅ Tap habits to toggle completion status (red X ↔ green checkmark)
- ✅ Force quit and reopen app - habits and completions persist
- ✅ Edit habit title via swipe action
- ✅ Archive habit and verify it disappears from Today view

