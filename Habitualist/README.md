# Habitualist

A beautiful, modern habit tracking application for iPhone built with SwiftUI and SwiftData. Track your daily habits, monitor weekly progress, and view your completion history through an intuitive calendar interface.

![iOS 17.0+](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-orange.svg)
![SwiftData](https://img.shields.io/badge/SwiftData-1.0-green.svg)

## Features

### Core Functionality
- **Habit Management**: Create, edit, and archive habits with custom titles
- **Daily Tracking**: Mark habits as complete with a simple tap
- **Weekly Targets**: Set custom weekly goals (1-7 days) for each habit
- **Progress Tracking**: Visual progress indicators showing weekly completion status
- **Smart Completion States**: Habits turn blue when completed today or weekly target is met

### Calendar & History
- **In-App Calendar**: Browse past days through an interactive month calendar
- **Historical Summaries**: View detailed daily summaries for any date
- **Completion Indicators**: Visual dots and blue highlights show completed days
- **Week-Based Progress**: Weekly progress calculated relative to any selected date

### User Experience
- **Dark Theme Design**: Modern dark UI inspired by Dribbble design references
- **Card-Based Interface**: Beautiful rounded cards with subtle borders and smooth animations
- **Collapsible Calendar**: Expandable calendar section for easy navigation
- **Onboarding Flow**: Intuitive setup process for new users
- **Settings**: Appearance preferences and optional Apple Calendar integration

### Data & Integration
- **Local-Only Storage**: All data stored locally using SwiftData (privacy-first)
- **Apple Calendar Integration**: Optional export of daily summaries to Apple Calendar
- **Timezone Aware**: Proper date handling using device timezone
- **Persistent History**: Complete habit completion history stored indefinitely

## Screenshots

> **Note**: Add screenshots of your app here. You can add images like:
> - `screenshots/today-view.png`
> - `screenshots/calendar-view.png`
> - `screenshots/daily-summary.png`

## Tech Stack

- **Framework**: SwiftUI 5.0
- **Data Persistence**: SwiftData
- **Architecture**: MVVM-style with clean separation of concerns
- **Design Pattern**: Declarative UI with reactive data flow
- **Calendar Integration**: EventKit for Apple Calendar export
- **Minimum iOS**: 17.0+

## Architecture

### Project Structure

```
Habitualist/
├── HabitualistApp.swift          # App entry point with SwiftData setup
├── Theme/
│   └── Theme.swift               # Centralized theme system (colors, fonts, styles)
├── Models/
│   ├── Habit.swift               # SwiftData model for habits
│   └── Completion.swift          # SwiftData model for daily completions
├── Services/
│   ├── DayKeyService.swift       # Date key helper using device timezone
│   ├── WeeklyProgressService.swift # Weekly progress calculation logic
│   └── CalendarEventService.swift # Apple Calendar integration
└── Views/
    ├── RootView.swift            # Root navigation controller
    ├── OnboardingView.swift      # First-time user setup
    ├── TodayView.swift           # Main screen with habit list
    ├── MonthCalendarView.swift   # Calendar grid for browsing history
    ├── DailySummaryView.swift    # Today's summary view
    ├── DailySummaryByDateView.swift # Historical date summary view
    ├── AddHabitView.swift        # Form to add new habits
    ├── EditHabitView.swift       # Form to edit/archive habits
    └── SettingsView.swift        # App settings and preferences
```

### Key Design Decisions

- **SwiftData over Core Data**: Leverages modern Swift concurrency and declarative APIs
- **Local-Only Storage**: Privacy-focused, no cloud sync requirements
- **Theme System**: Centralized design tokens for consistent styling
- **Date Key System**: String-based date keys (YYYY-MM-DD) for efficient querying
- **ISO Calendar**: Monday-start weeks for consistent weekly calculations
- **Card-Based UI**: Modern, accessible interface with clear visual hierarchy

## Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- iPhone device or simulator

## Installation

### Clone the Repository

```bash
git clone https://github.com/DimePrangija/Habitualist.git
cd Habitualist/Habitualist
```

### Open in Xcode

1. Open `Habitualist.xcodeproj` in Xcode 15.0+
2. Select your target device or simulator (iPhone recommended)
3. Build and run (⌘R)

### First Run

- The app will show the onboarding screen if no habits exist
- Add your first habits and set weekly targets
- Start tracking your daily progress!

## Usage

### Adding Habits
1. Tap "Add new habits" button on the main screen
2. Enter a habit title
3. Set your weekly target (1-7 days)
4. Tap Save

### Tracking Completion
- Tap anywhere on a habit card to mark it complete for today
- Completed habits turn blue with a checkmark icon
- Weekly progress updates automatically

### Viewing History
1. Scroll to the bottom of the main screen
2. Tap "Calendar" to expand the calendar view
3. Navigate between months using arrow buttons
4. Tap any date to view its detailed summary

### Settings
- Access settings via the gear icon in the top right
- Change appearance preferences (System/Light/Dark)
- Enable Apple Calendar integration for daily summaries

## Development

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftUI best practices (declarative, compositional)
- Maintain clean separation between Models, Views, and Services

### Adding Features
1. Create a new branch for your feature
2. Follow existing code patterns and architecture
3. Update README if adding significant functionality
4. Test thoroughly on device and simulator

## Data Storage

All data is stored locally on the device using SwiftData:
- **Location**: Local SQLite database in app container
- **Persistence**: Permanent (until app deletion)
- **Privacy**: No cloud sync, no external servers
- **Capacity**: Effectively unlimited for normal usage

## License

This project is available for portfolio/resume demonstration purposes.

## Author

Nikola Dimitrijevic

