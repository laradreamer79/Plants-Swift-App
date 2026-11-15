import SwiftUI

struct PlantsList: View {
    let plantListViewModel: PlantListViewModel

    @State private var showReminder = false
    @State private var selectedPlant: PlantList?

    var body: some View {
        NavigationStack {
            List {
                    PlantHeader()
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.black)

                    if plantListViewModel.plants.isEmpty {
                        EmptyView()
                    } else if plantListViewModel.allPlantsWatered {
                        AllRemindersCompleted()
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.black)
                    } else {
                        WateringSummary(
                            wateredCount: plantListViewModel.wateredCount,
                            totalCount: plantListViewModel.plants.count,
                            progress: plantListViewModel.wateringProgress,
                            message: plantListViewModel.wateringMessage
                        )
                        .padding(.horizontal, 26)
                        .padding(.top, 38)
                        .padding(.bottom, 46)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)

                            ForEach(plantListViewModel.plants) { plant in
                                PlantCareRow(plant: plant, onToggleWatered: {
                                    plantListViewModel.toggleWatered(for: plant.id)
                                }, onEdit: {
                                    selectedPlant = plant
                                })
                                .listRowInsets(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        plantListViewModel.deletePlant(id: plant.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    .tint(.red)
                                }
                            }
                    }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .environment(\.defaultMinListRowHeight, 0)
            .background(Color.black)
            .overlay {
                if plantListViewModel.plants.isEmpty {
                    Text("No reminders set yet..")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.gray)
                        .allowsHitTesting(false)
                }
            }
            .safeAreaInset(edge: .bottom, alignment: .trailing) {
                Button {
                    showReminder = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 46, height: 46)
                        .background(
                            Color(red: 0.13, green: 0.45, blue: 0.37),
                            in: Circle()
                        )
                        .overlay {
                            Circle()
                                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add plant")
                .padding(.trailing, 24)
                .padding(.bottom, 16)
                .padding(.top, 12)
            }
        }
        .sheet(isPresented: $showReminder) {
            SetReminder(plantListViewModel: plantListViewModel)
        }
        .sheet(item: $selectedPlant) { plant in
            SetReminder(plantListViewModel: plantListViewModel, plant: plant)
        }
        .preferredColorScheme(.dark)
    }
}

private struct AllRemindersCompleted: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("plant")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220, maxHeight: 240)
                .accessibilityHidden(true)
                .padding(.bottom, 28)

            Text("All Done! 🎉")
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text("All Reminders Completed")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 110)
        .padding(.bottom, 40)
    }
}

private struct WateringSummary: View {
    let wateredCount: Int
    let totalCount: Int
    let progress: Double
    let message: LocalizedStringResource

    var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(white: 0.15))
                    Capsule()
                        .fill(.mint)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
            .accessibilityElement()
            .accessibilityLabel("Watering progress")
            .accessibilityValue("\(wateredCount) of \(totalCount) plants watered")
        }
    }
}

private struct PlantCareRow: View {
    let plant: PlantList
    let onToggleWatered: () -> Void
    let onEdit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    onToggleWatered()
                } label: {
                    Image(systemName: plant.isWatered ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 25, weight: .ultraLight))
                        .foregroundStyle(plant.isWatered ? Color.mint : Color.gray)
                        .frame(width: 40, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(plant.isWatered
                                    ? "Mark \(plant.name) as not watered"
                                    : "Mark \(plant.name) as watered")

                Button(action: onEdit) {
                    VStack(alignment: .leading, spacing: 8) {
                    Label("in \(plant.room.rawValue.capitalized)", systemImage: "location")
                        .font(.subheadline)
                        .foregroundStyle(.gray)

                    Text(plant.name)
                        .font(.largeTitle)
                        .foregroundStyle(plant.isWatered ? .gray : .white)

                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 12) {
                            PlantLightBadge(light: plant.light)
                            PlantWaterBadge(water: plant.water)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            PlantLightBadge(light: plant.light)
                            PlantWaterBadge(water: plant.water)
                        }
                    }
                    .opacity(plant.isWatered ? 0.6 : 1)
                }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityHint("Edit reminder")
            }
            .padding(.vertical, 12)

            Divider()
        }
    }
}

private struct PlantLightBadge: View {
    let light: Light

    var body: some View {
        Label(light.rawValue, systemImage: "sun.max")
            .font(.subheadline)
            .foregroundStyle(Color(red: 0.80, green: 0.77, blue: 0.44))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(white: 0.095), in: RoundedRectangle(cornerRadius: 9))
    }
}

private struct PlantWaterBadge: View {
    let water: Water

    var body: some View {
        Label(water.rawValue, systemImage: "drop")
            .font(.subheadline)
            .foregroundStyle(Color(red: 0.73, green: 0.91, blue: 0.95))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(white: 0.095), in: RoundedRectangle(cornerRadius: 9))
    }
}

private struct PlantsListPreview: View {
    @State private var viewModel: PlantListViewModel

    init(showSamplePlants: Bool) {
        let viewModel = PlantListViewModel()
        if showSamplePlants {
            viewModel.plants = [
                PlantList(id: UUID(), name: "Monstera", room: .kitchen),
                PlantList(id: UUID(), name: "Pothos", room: .bedroom),
                PlantList(id: UUID(), name: "Orchid", room: .livingroom),
                PlantList(id: UUID(), name: "Spider", room: .kitchen)
            ]
        }
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        PlantsList(plantListViewModel: viewModel)
    }
}

#Preview("Plant collection") {
    PlantsListPreview(showSamplePlants: true)
}

#Preview("Empty collection") {
    PlantsListPreview(showSamplePlants: false)
}
