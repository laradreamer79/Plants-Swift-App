import Foundation
import Observation

@MainActor
@Observable
final class SetReminderViewModel {
    var room: Room = .bedroom
    var light: Light = .fullSun
    var wateringDays: WateringDays = .EveryDay
    var water: Water = .ml20To50
    var plantName: String = ""

    let plantID: UUID?

    init(plant: PlantList? = nil) {
        plantID = plant?.id
        if let plant {
            plantName = plant.name
            room = plant.room
            light = plant.light
            water = plant.water
            wateringDays = plant.wateringDays
        }
    }

    func save(to list: PlantListViewModel) {
        let plant = PlantList(
            id: plantID ?? UUID(),
            name: plantName,
            room: room,
            light: light,
            water: water,
            wateringDays: wateringDays
        )
        if plantID != nil {
            list.updatePlant(plant)
        } else {
            list.addPlant(plant)
        }
    }

    func delete(from list: PlantListViewModel) {
        guard let plantID else { return }
        list.deletePlant(id: plantID)
    }
}
