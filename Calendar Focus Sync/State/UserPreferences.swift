import Foundation
import Combine
import EventKit
import LaunchAtLogin


class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    @Published var nativeCalendarAccess: EKAuthorizationStatus.RawValue
    @Published var selectedPriorTimeBuffer: Int {
        didSet {
            UserDefaults.standard.set(selectedPriorTimeBuffer, forKey: "selectedPriorTimeBuffer")
        }
    }
        
    init() {
        self.selectedPriorTimeBuffer = UserDefaults.standard.object(forKey: "selectedPriorTimeBuffer") as? Int ?? 1
        self.nativeCalendarAccess = EKEventStore.authorizationStatus(for: .event).rawValue
    }
}
