import Foundation

struct PlantList: Identifiable, Codable {
    let id: UUID
    var name: String
    var room: Room = .bedroom
    var light: Light = .fullSun
    var water: Water = .ml20To50
    var wateringDays: WateringDays = .EveryDay
    var isWatered = false
    var nextWateringDate: Date?
}
