import SwiftUI

@main struct MyApp: App {
    init() {
        _ = PlantNotificationService.shared
    }

    var body: some Scene {
        WindowGroup {
            Home()
                .preferredColorScheme(.dark)
        }
    }
}
