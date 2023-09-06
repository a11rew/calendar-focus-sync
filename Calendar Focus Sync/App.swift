import SwiftUI

@main
struct AppMain: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject var userPreferences = UserPreferences.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(userPreferences)
            
            Spacer()
        }
    }
}

@MainActor
private final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
            let syncOrchestrator = SyncOrchestrator(userPreferences: UserPreferences.shared, syncHandlers: [
                NativeCalendarSync()
            ])
            
            syncOrchestrator.go()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Tear down services
    }
}
