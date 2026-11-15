import Foundation
import Observation

@MainActor
@Observable
final class PlantListViewModel {
    var plants: [PlantList] = [] {
        didSet { persistPlants() }
    }
    var notificationMessage: String?
    private let usesNotifications: Bool
    private let storageKey = "savedPlants"
    @ObservationIgnored private var notificationTask: Task<Void, Never>?

    init(usesNotifications: Bool = false) {
        self.usesNotifications = usesNotifications
        if usesNotifications,
           let data = UserDefaults.standard.data(forKey: storageKey),
           let saved = try? JSONDecoder().decode([PlantList].self, from: data) {
            plants = saved
        }
        refreshWateringStatus()
    }

    func refreshWateringStatus() {
        let now = Date()
        for index in plants.indices {
            if let dueDate = plants[index].nextWateringDate, dueDate <= now {
                plants[index].isWatered = false
            }
        }
    }

    private func persistPlants() {
        guard usesNotifications else { return }
        do {
            let data = try JSONEncoder().encode(plants)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            notificationMessage = "Your plants could not be saved. Please try again."
        }
    }

    private func scheduleNotification(for plant: PlantList) {
        guard usesNotifications else { return }
        let previousTask = notificationTask
        // Serialize edits and deletions so a late scheduling request cannot recreate a deleted reminder.
        notificationTask = Task {
            await previousTask?.value
            do {
                let allowed = try await PlantNotificationService.shared.schedule(plant)
                if !allowed {
                    notificationMessage = "Your plant is saved. Enable notifications for Plants in Settings to receive watering reminders."
                }
            } catch {
                notificationMessage = "Your plant is saved, but its notification could not be scheduled: \(error.localizedDescription)"
            }
        }
    }

    private func nextDate(for plant: PlantList) -> Date {
        Date().addingTimeInterval(TimeInterval(plant.wateringDays.intervalDays * 86_400))
    }

    var allPlantsWatered: Bool {
        !plants.isEmpty && wateredCount == plants.count
    }

    var wateredCount: Int {
        plants.filter { $0.isWatered }.count
    }

    var wateringMessage: LocalizedStringResource {
        let count = wateredCount
        if count == 0 {
            return "Your plants are waiting for a sip 💦"
        }
        if count == 1 {
            return "1 of your plants feels loved today✨"
        }
        return "\(count) of your plants feel loved today✨"
    }

    var wateringProgress: Double {
        guard !plants.isEmpty else { return 0 }
        return Double(wateredCount) / Double(plants.count)
    }

    func addPlant(_ plant: PlantList) {
        var savedPlant = plant
        savedPlant.nextWateringDate = nextDate(for: plant)
        plants.append(savedPlant)
        scheduleNotification(for: savedPlant)
    }

    func updatePlant(_ plant: PlantList) {
        guard let index = plants.firstIndex(where: { $0.id == plant.id }) else { return }
        var updatedPlant = plant
        // Editing care details must preserve the current watering status.
        updatedPlant.isWatered = plants[index].isWatered
        updatedPlant.nextWateringDate = nextDate(for: updatedPlant)
        plants[index] = updatedPlant
        scheduleNotification(for: updatedPlant)
    }

    func deletePlant(id: UUID) {
        plants.removeAll { $0.id == id }
        guard usesNotifications else { return }
        let previousTask = notificationTask
        notificationTask = Task {
            await previousTask?.value
            PlantNotificationService.shared.cancel(id: id)
        }
    }

    func toggleWatered(for plantID: UUID) {
        guard let index = plants.firstIndex(where: { $0.id == plantID }) else { return }
        plants[index].isWatered.toggle()
        if plants[index].isWatered {
            plants[index].nextWateringDate = nextDate(for: plants[index])
            if usesNotifications {
                PlantNotificationService.shared.clearDelivered(id: plantID)
            }
            scheduleNotification(for: plants[index])
        }
    }
}
