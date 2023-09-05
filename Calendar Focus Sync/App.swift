import SwiftUI

@main
struct AppMain: App {
    @StateObject var userPreferences = UserPreferences()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(userPreferences)
            
            Spacer()
        }
    }
}
