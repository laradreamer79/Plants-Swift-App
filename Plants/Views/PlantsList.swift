import SwiftUI

struct PlantsList: View {
    let plantListViewModel: PlantListViewModel

    @State private var showReminder = false

    var body: some View {
        @Bindable var viewModel = plantListViewModel

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("My Plants 🌱")
                        .font(.largeTitle.bold())
                        .padding(.horizontal, 16)
                        .padding(.top, 24)
                        .padding(.bottom, 22)

                    Divider()
                        .padding(.horizontal, 16)

                    if viewModel.plants.isEmpty {
                        ContentUnavailableView(
                            "Your collection starts here",
                            systemImage: "leaf",
                            description: Text("Add a plant to keep its care details in one place.")
                        )
                        .padding(.vertical, 40)
                    } else {
                        WateringSummary(
                            wateredCount: viewModel.plants.filter { $0.isWatered }.count,
                            totalCount: viewModel.plants.count
                        )
                        .padding(.horizontal, 26)
                        .padding(.top, 38)
                        .padding(.bottom, 46)

                        LazyVStack(spacing: 0) {
                            ForEach($viewModel.plants) { $plant in
                                PlantCareRow(plant: $plant)
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                }
                .padding(.bottom, 24)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .background(Color.black)
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
            .sheet(isPresented: $showReminder) {
                SetReminder(plantListViewModel: plantListViewModel)
            }
        }
        .preferredColorScheme(.dark)
    }
}

private struct WateringSummary: View {
    let wateredCount: Int
    let totalCount: Int

    var body: some View {
        VStack(spacing: 16) {
            Text(wateredCount == totalCount
                 ? "Your plants are all watered 🌿"
                 : "Your plants are waiting for a sip 💦")
                .font(.body)
                .multilineTextAlignment(.center)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(white: 0.15))
                    Capsule()
                        .fill(.mint)
                        .frame(width: geometry.size.width * Double(wateredCount) / Double(max(totalCount, 1)))
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
    @Binding var plant: PlantList

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    plant.isWatered.toggle()
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

#Preview("Plant collection") {
    let viewModel = PlantListViewModel()
    viewModel.plants = [
        PlantList(id: UUID(), name: "Monstera", room: .kitchen),
        PlantList(id: UUID(), name: "Pothos", room: .bedroom),
        PlantList(id: UUID(), name: "Orchid", room: .livingroom),
        PlantList(id: UUID(), name: "Spider", room: .kitchen)
    ]
    return PlantsList(plantListViewModel: viewModel)
}

#Preview("Empty collection") {
    PlantsList(plantListViewModel: PlantListViewModel())
}
