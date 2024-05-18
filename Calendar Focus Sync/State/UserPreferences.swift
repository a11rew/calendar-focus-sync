import Foundation
import Combine
import EventKit
import LaunchAtLogin

let defaults = UserDefaults.standard

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    @Published var nativeCalendarAccessGranted: Bool {
        didSet {
            Task {
                if nativeCalendarAccessGranted {
                    // Trigger calendar sync
                    await SyncOrchestrator.shared.go()
                }
            }
        }
    }
    
    @Published var notificationsAccessGranted: Bool {
        didSet {
            defaults.set(notificationsAccessGranted, forKey: "notificationsAccessGranted")
            
            Task {
                if nativeCalendarAccessGranted {
                    await SyncOrchestrator.shared.go()
                }
            }
        }
    }
    
    
    @Published var selectedPriorTimeBuffer: Int {
        didSet {
            defaults.set(selectedPriorTimeBuffer, forKey: "selectedPriorTimeBuffer")
            
            Task {
                if nativeCalendarAccessGranted {
                    await SyncOrchestrator.shared.go()
                }
            }
        }
    }
    
    @Published var excludedCalendarIds: [String] = [] {
        didSet {
            defaults.set(excludedCalendarIds, forKey: "excludedCalendarIds")
            
            Task {
                if nativeCalendarAccessGranted {
                    await SyncOrchestrator.shared.go()
                }
            }
        }
    }
    
    init() {
        self.nativeCalendarAccessGranted = EKEventStore.authorizationStatus(for: .event) == .fullAccess
        self.selectedPriorTimeBuffer = defaults.integer(forKey: "selectedPriorTimeBuffer") != 0 ? defaults.integer(forKey: "selectedPriorTimeBuffer") : 5
        self.notificationsAccessGranted = defaults.bool(forKey: "notificationsAccessGranted")
        self.excludedCalendarIds = defaults.object(forKey: "excludedCalendarIds") as? [String] ?? []
    }
}
