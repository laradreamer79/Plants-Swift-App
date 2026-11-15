import Foundation
import UserNotifications

@MainActor
final class PlantNotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = PlantNotificationService()
    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        center.delegate = self
    }

    func schedule(_ plant: PlantList) async throws -> Bool {
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            guard try await center.requestAuthorization(options: [.alert, .sound]) else {
                return false
            }
        } else if settings.authorizationStatus == .denied {
            return false
        }

        let pending = await center.pendingNotificationRequests()
        let requestID = identifier(for: plant.id)
        guard pending.count < 64 || pending.contains(where: { $0.identifier == requestID }) else {
            throw SchedulingError.limitReached
        }

        let content = UNMutableNotificationContent()
        content.title = "Plant watering reminder"
        content.body = "Hey! Let's water \(plant.name) 🪴"
        content.sound = .default
        content.userInfo = ["plantID": plant.id.uuidString]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(plant.wateringDays.intervalDays * 24 * 60 * 60),
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: identifier(for: plant.id),
            content: content,
            trigger: trigger
        )
        try await center.add(request)
        return true
    }

    func cancel(id: UUID) {
        let identifiers = [identifier(for: id)]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    func clearDelivered(id: UUID) {
        center.removeDeliveredNotifications(withIdentifiers: [identifier(for: id)])
    }

    private enum SchedulingError: LocalizedError {
        case limitReached

        var errorDescription: String? {
            "The notification limit has been reached. Remove an unused reminder and save this plant again."
        }
    }

    private func identifier(for id: UUID) -> String {
        "plant-watering-" + id.uuidString
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .list]
    }
}

extension WateringDays {
    var intervalDays: Int {
        switch self {
        case .EveryDay: 1
        case .Every2Days: 2
        case .Every3Days: 3
        case .OnceaWeek: 7
        case .Every10Days: 10
        case .Every2Weeks: 14
        }
    }
}
