import Foundation
import Observation

@MainActor
@Observable
final class PlantListViewModel {
    var plants: [PlantList] = []

    var wateredCount: Int {
        plants.filter { $0.isWatered }.count
    }

    var wateringProgress: Double {
        guard !plants.isEmpty else { return 0 }
        return Double(wateredCount) / Double(plants.count)
    }

    func addPlant(_ plant: PlantList) {
        plants.append(plant)
    }

    func toggleWatered(for plantID: UUID) {
        guard let index = plants.firstIndex(where: { $0.id == plantID }) else { return }
        plants[index].isWatered.toggle()
    }
}
