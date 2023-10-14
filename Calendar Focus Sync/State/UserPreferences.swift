import Foundation
import Combine
import EventKit
import LaunchAtLogin

let defaults = UserDefaults.standard

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    @Published var nativeCalendarAccessGranted: Bool {
        didSet {
            // Trigger calendar sync
            SyncOrchestrator(userPreferences: UserPreferences.shared, syncHandlers: [NativeCalendarSync()]).go()
        }
    }
    @Published var selectedPriorTimeBuffer: Int {
        didSet {
            defaults.set(selectedPriorTimeBuffer, forKey: "selectedPriorTimeBuffer")
        }
    }
        
    init() {
        self.nativeCalendarAccessGranted = EKEventStore.authorizationStatus(for: .event) == .fullAccess
        self.selectedPriorTimeBuffer = defaults.integer(forKey: "selectedPriorTimeBuffer") != 0 ? defaults.integer(forKey: "selectedPriorTimeBuffer") : 5
    }
}
