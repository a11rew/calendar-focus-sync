import Foundation
import Combine

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isShortCutInstalled: Bool = false
    @Published var calendarEvents: [CalendarEvent] = []
        
    init() {
        self.isShortCutInstalled = isShortcutInstalled()
    }
}
