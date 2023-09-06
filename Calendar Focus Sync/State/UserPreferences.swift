import Foundation
import Combine
import EventKit

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    @Published var nativeCalendarAccess: EKAuthorizationStatus.RawValue

    @Published var selectedPriorTimeBuffer: TimeBefore.RawValue {
        didSet {
            UserDefaults.standard.set(selectedPriorTimeBuffer, forKey: "selectedPriorTimeBuffer")
        }
    }
    
    @Published var launchOnLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchOnLogin, forKey: "launchOnLogin")
        }
    }
        
    init() {
        self.selectedPriorTimeBuffer = UserDefaults.standard.object(forKey: "selectedPriorTimeBuffer") as? TimeBefore.RawValue ?? TimeBefore.one_minute.rawValue
        self.launchOnLogin = UserDefaults.standard.object(forKey: "launchOnLogin") as? Bool ?? false
        self.nativeCalendarAccess = EKEventStore.authorizationStatus(for: .event).rawValue
    }
}
