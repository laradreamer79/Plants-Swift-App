# Plants 🪴

A SwiftUI iOS app for keeping plant care details in one place and remembering when to water them. Add your plants, choose a watering interval, and track watering progress with local reminders.

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

## Local notifications

Notifications use Apple’s `UserNotifications` framework; no notification server is required. A typical message is:

> **Plant watering reminder**
> Hey! Let's water Pothos 🪴

Supported intervals are **1, 2, 3, 7, 10, and 14 days**. The service converts each interval to seconds and creates a repeating `UNTimeIntervalNotificationTrigger`.

- The first saved reminder requests alert and sound permission when permission has not been determined.
- Saving an edit replaces the plant’s existing request using its stable UUID-based identifier.
- Marking a plant watered restarts its interval and clears its delivered notification.
- Deleting a plant removes its pending and delivered notifications.
- Scheduling and cancellation run in sequence to avoid a delayed request recreating a deleted reminder.
- The service requests banner, sound, and Notification Center presentation while the app is open.
- If permission is denied or scheduling fails, the plant remains saved and the app displays a message.

Intervals are measured from scheduling, not a fixed time of day. For example, “Every 2 Days” means every 48 hours. Editing a reminder also restarts that interval. Delivery and presentation depend on the device’s notification settings.

If permission was denied, enable notifications in iOS Settings, then save the plant’s reminder again to schedule it. The service includes a guard against adding a new request when 64 notifications are already pending.

## Persistence

The current implementation uses **Codable JSON stored in UserDefaults**, under the key `savedPlants`. It does **not** use SwiftData or cloud synchronization.

Changes to the plant array trigger a save. The view model restores the array during initialization. On launch and when the app becomes active, plants whose next watering date has passed are marked as needing water again.

The `usesNotifications` flag currently controls both notification operations and persistence. The running `Home` enables it; canvas previews and default view-model instances keep it disabled so sample data does not schedule reminders or overwrite saved plants.

## Manual verification

1. Add a plant and check its displayed details.
2. Edit its name and care options; confirm saving updates the same plant.
3. Change a draft and close with **X**; confirm the saved details stay unchanged.
4. Mark plants watered and check the progress and completion screen.
5. Delete a plant using both supported deletion paths.
6. Close and relaunch the running app to check restored data.
7. Check notification permission and delivery in the running app. Normal schedules start after the selected interval, so the shortest production reminder is 24 hours after scheduling.

## Current scope

- Plant data is stored locally on the device, with no account or cross-device sync.
- Watering status refreshes on launch or app activation; there is no continuous background status refresh.
- The completion screen hides plant rows until a plant becomes due or an unwatered plant is added.
- Notifications carry a plant ID, but tapping one does not currently navigate directly to that plant’s editor.
