//
//  SetReminder.swift
//  Plants
//
//  Created by LARA on 01/06/1448 AH.
//

import SwiftUI

struct SetReminder: View {
    
    @State private var viewModel: SetReminderViewModel
    let plantListViewModel: PlantListViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    init(plantListViewModel: PlantListViewModel, plant: PlantList? = nil) {
        self.plantListViewModel = plantListViewModel
        _viewModel = State(initialValue: SetReminderViewModel(plant: plant))
    }

    var body: some View {
        
        NavigationStack{
        ZStack{
            Color.sheet
                .ignoresSafeArea()
            VStack{
                
                    Form{
                        Section{
                            HStack{
                                Text("Plant Name")
                                TextField("Pothos", text: $viewModel.plantName)
                                
                            }.foregroundStyle(.white)
                        }
                        .listRowBackground(Color.field)
                        Section{
                            
                            Picker(selection: $viewModel.room) {
                                ForEach(Room.allCases) { room in
                                    Text(room.rawValue)
                                        .tag(room)
                                }
                            } label: {
                                Label("Room", systemImage: "location")
                            }
                            
                            
                            
                            
                            Picker(selection: $viewModel.light) {
                                ForEach(Light.allCases) { light in
                                    Text(light.rawValue)
                                        .tag(light)
                                }
                            } label: {
                                Label("Light", systemImage: "sun.max")
                            }
                            
                            
                            
                        }
                        .foregroundStyle(.white)
                        .listRowBackground(Color.field)
                        .listRowSeparator(.visible, edges: .bottom)
                        .listRowSeparatorTint(.fieldlabel)
                        
                        Section{
                            
                            Picker(selection: $viewModel.wateringDays) {
                                ForEach(WateringDays.allCases) { wateringDays in
                                    Text(wateringDays.rawValue)
                                        .tag(wateringDays)
                                }
                            } label: {
                                Label("Watering Days", systemImage: "drop")
                            }
                            Picker(selection: $viewModel.water) {
                                ForEach(Water.allCases) { water in
                                    Text(water.rawValue)
                                        .tag(water)
                                }
                            } label: {
                                Label("Water", systemImage: "drop")
                            }
                            
                            
                            
                        }
                        .listRowSeparatorTint(.fieldlabel)
                        .foregroundStyle(.white)
                        .listRowBackground(Color.field)
                        if viewModel.plantID != nil {
                            Section {
                                Button(role: .destructive) {
                                    viewModel.delete(from: plantListViewModel)
                                    dismiss()
                                } label: {
                                    Text("Delete Reminder")
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                }
                            }
                            .listRowBackground(Color.field)
                        }
                    }
                    .tint(.pickeroption)
                    .scrollContentBackground(.hidden)
                }
                .navigationTitle("Set Reminder")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()                        } label: {
                            Image(systemName: "xmark")
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            viewModel.save(to: plantListViewModel)

                            dismiss()
                        } label: {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            
                .scrollContentBackground(.hidden)
                

            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
    }
}


#Preview {
    SetReminder(plantListViewModel: PlantListViewModel())
}
