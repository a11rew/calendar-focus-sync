import Foundation
import Combine
import EventKit

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isShortCutInstalled: Bool = false
    @Published var calendarEvents: [CalendarEvent] = []
    @Published var calendars: [EKCalendar] = []
    
        
    init() {
        self.isShortCutInstalled = isShortcutInstalled()
    }
}
