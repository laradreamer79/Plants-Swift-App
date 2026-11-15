import SwiftUI
import UIKit


struct Home: View{
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSheet = false
    @State private var hasOpenedReminder = false
    @State private var plantListViewModel = PlantListViewModel(usesNotifications: ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1")

    var body: some View{
        ZStack {
            if !hasOpenedReminder && plantListViewModel.plants.isEmpty {
                welcomeView
            } else {
                PlantsList(plantListViewModel: plantListViewModel)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                plantListViewModel.refreshWateringStatus()
            }
        }
        .alert("Watering Notifications", isPresented: Binding(
            get: { plantListViewModel.notificationMessage != nil },
            set: { if !$0 { plantListViewModel.notificationMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                plantListViewModel.notificationMessage = nil
            }
        } message: {
            Text(plantListViewModel.notificationMessage ?? "")
        }
        .sheet(isPresented: $showSheet, onDismiss: {
            hasOpenedReminder = true
        }) {
            SetReminder(plantListViewModel: plantListViewModel)
        }
    }

    private var welcomeView: some View {
        ZStack{
            
            Color.black
                .ignoresSafeArea()
            
            VStack{
                
                
                VStack{
                   PlantHeader()
                }
                
                
                Image("plant")
                    .frame(width: 167, height: 200)
                    .padding(.bottom, 37)
                    .padding(.top, 98)
                
                VStack{
                    Text("Start your plants journey!")
                        .foregroundStyle(.white)
                        .font(.custom("SFCompactDisplay-Semibold", size: 25))
                        .onAppear{
                            print("font check", UIFont(name: "SFCompactDisplay-Semibold", size: 25))
                        }
                    
                    Text("Now all your plants will be in one place and we will help you take care of them :)🪴")
                        .foregroundStyle(Color(red: 0.624, green: 0.624, blue: 0.569, opacity: 1.00))
                        .font(.custom("SFCompactDisplay-Regular", size: 16))
                        .padding(.top)
                }
                .frame(width: 315, height: 93)
                
                Button {
                    showSheet = true
                } label: {
                    Text("Set Plant Reminder")
                        .padding()
                        .frame(width: 280, height: 42)
                        .background(
                            Color(red: 0.200, green: 0.502, blue: 0.412, opacity: 1.00),
                            in: RoundedRectangle(cornerRadius: 30)
                        )
                        .padding(.top, 105)
                        .foregroundStyle(.white)
                    
                }
                
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
        }
    }
}

#Preview {
    Home()
}
