import SwiftUI

@main
struct AppMain: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject var userPreferences = UserPreferences.shared
    @StateObject var appState = AppState.shared
    
    var body: some Scene {
            Settings {
                SettingsView()
                    .environmentObject(userPreferences)
                    .environmentObject(appState)
                
                Spacer()
            }.windowStyle(HiddenTitleBarWindowStyle())

            
            MenuBarExtra {
                Text("Calendar Focus Sync").disabled(true)
                
                SettingsLink {
                    Text("Settings")
                }
                
                Divider()
                
                Button("Quit") {
                    NSApplication.shared.terminate(self)
                }
            } label: {
                Image(systemName: "calendar")
            }
        }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Listen for window becoming key (i.e., active)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeKey(notification:)), name: NSWindow.didBecomeKeyNotification, object: nil)
        
        notificationCenter.delegate = self
        
        Task {
            await SyncOrchestrator.shared.go()
        }
    
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Tear down services
    }
    
    
    @objc func windowDidBecomeKey(notification: Notification) {
        if let window = notification.object as? NSWindow, window === self.window {
            window.level = .floating // Make window show above others
        }
    }
}
