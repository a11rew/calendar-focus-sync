import Foundation
import Combine
import EventKit

class UserPreferences: ObservableObject {
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
    
    @Published var nativeCalendarAccess: EKAuthorizationStatus.RawValue {
        didSet {
            UserDefaults.standard.set(nativeCalendarAccess, forKey: "nativeCalendarAccess")
        }
    }
    
    func requestCalendarEventPermissions() {
        // Request access to event store
        store.requestAccess(to: .event, completion: { (isGranted: Bool, error: Error?) -> Void in
            if error != nil || !isGranted {
                print("Calendar permissions not granted: \(error as Error?)")
                return
            }
            
            self.nativeCalendarAccess = EKAuthorizationStatus.authorized.rawValue
        })
    }
    
    init() {
        self.selectedPriorTimeBuffer = UserDefaults.standard.object(forKey: "selectedPriorTimeBuffer") as? TimeBefore.RawValue ?? TimeBefore.one_minute.rawValue
        self.launchOnLogin = UserDefaults.standard.object(forKey: "launchOnLogin") as? Bool ?? false
        self.nativeCalendarAccess = UserDefaults.standard.object(forKey: "nativeCalendarAccess") as? EKAuthorizationStatus.RawValue ?? EKAuthorizationStatus.notDetermined.rawValue
    }
}
