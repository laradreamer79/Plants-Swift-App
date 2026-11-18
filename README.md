# Plants 🪴

A SwiftUI iOS app for keeping plant care details in one place and remembering when to water them. Add your plants, choose a watering interval, and track watering progress with local reminders.

<img width="1536" height="1024" alt="Plant Care App on iPhones" src="https://github.com/user-attachments/assets/2ede3b67-8978-4b13-9b37-da792a850088" />

## Features

- Add plants with a name, room, light preference, water amount, and watering interval.
- Edit a plant using the same reminder form, with changes applied only when saved.
- Mark plants watered and see progress and encouraging messages.
- Show an “All Done!” screen when every plant is marked watered.
- Delete a reminder from its form or swipe a plant left to reveal Delete.
- Receive repeating local watering notifications.
- Restore saved plants when the app launches again.
- Use a dark interface with a shared plant header and empty states.

## Getting started

1. Open `Plants.xcodeproj` in Xcode on a Mac.
2. Select the **Plants** scheme and an iPhone simulator or connected iPhone compatible with the target’s deployment version.
3. For a physical iPhone, select your development team under **Signing & Capabilities**.
4. Build and run with **⌘R**.
5. Tap **Set Plant Reminder**, enter the plant’s details, and tap the checkmark.
6. Allow notifications when prompted if you want watering alerts.

The app launches into `Home` through `MyApp.swift`. Use Xcode’s canvas previews to explore the UI; use the running app to check notification permission, delivery, and persistence.

## Using the app

| Action | Result |
|---|---|
| Tap **+** | Open a new reminder form |
| Tap a plant’s name or details | Edit its existing reminder |
| Tap the checkmark in the form | Save the new plant or apply edits |
| Tap **X** | Close the form without saving its draft |
| Tap the circle beside a plant | Toggle its watered status |
| Swipe a plant left | Reveal the Delete action |
| Tap **Delete Reminder** while editing | Remove the plant and its notification |

Closing the first reminder form without saving leads to “No reminders set yet..”. When all plants are watered, the list is replaced by the completion screen; the add button remains available.

## Architecture

The project uses MVVM with a separate notification service. Views display state and forward actions to view models.

| File | Responsibility |
|---|---|
| `Models/PlantList.swift` | One plant’s identity, care details, watered status, and next watering date |
| `Models/PlantOptions.swift` | Room, light, water amount, and watering interval choices |
| `ViewModels/PlantListViewModel.swift` | Plant collection, add/edit/delete actions, progress, persistence, and notification coordination |
| `ViewModels/SetReminderViewModel.swift` | Editable form draft and save/delete actions |
| `ViewModels/PlantNotificationService.swift` | Notification permission, scheduling, cancellation, and foreground presentation |
| `Views/mainView.swift` | `Home`: welcome flow, shared view model, and notification feedback |
| `Views/PlantsList.swift` | Plant rows, watering progress, empty/completed states, and sheet presentation |
| `Views/SetReminder.swift` | Shared add/edit reminder form |
| `Component/plantHeader.swift` | Reusable `PlantHeader` view |
| `MyApp.swift` | App entry point and notification service initialization |

All paths in this table are relative to `Plants/`.

```text
User action in a SwiftUI view
    → View model updates plant data
    → Collection changes are saved locally
    → Notification service updates the scheduled reminder
    → SwiftUI reflects the updated state
```

The view models use Observation’s `@Observable` macro. Asynchronous notification operations use Swift concurrency (`Task`, `async`, and `await`).
