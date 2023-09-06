import Foundation
import Combine
import EventKit
import LaunchAtLogin


class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    @Published var nativeCalendarAccess: EKAuthorizationStatus.RawValue
    @Published var selectedPriorTimeBuffer: TimeBefore.RawValue {
        didSet {
            UserDefaults.standard.set(selectedPriorTimeBuffer, forKey: "selectedPriorTimeBuffer")
        }
    }
        
    init() {
        self.selectedPriorTimeBuffer = UserDefaults.standard.object(forKey: "selectedPriorTimeBuffer") as? TimeBefore.RawValue ?? TimeBefore.one_minute.rawValue
        self.nativeCalendarAccess = EKEventStore.authorizationStatus(for: .event).rawValue
    }
}
