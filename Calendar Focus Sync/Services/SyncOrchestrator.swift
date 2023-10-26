import EventKit
import Foundation

protocol CalendarSyncer {
    var identifier: String { get }
    
    func sync(syncFilter: SyncFilter) async -> [CalendarEvent]
}

struct CalendarEvent {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
}

struct SyncFilter {
    let startDate: Date
    let endDate: Date
    let calendars: [String] // ids of calendars to sync
}

let SYNC_DAYS_OUT = 30

let defaultSyncFilter = SyncFilter(
    startDate: Date(), // Only care about events that haven't begun
    endDate: Date().addingTimeInterval(TimeInterval(60 * 60 * 24 * SYNC_DAYS_OUT)),
    calendars: []
)

class SyncOrchestrator {
    private var events: [CalendarEvent]
    private let userPreferences: UserPreferences
    private let calendarSyncHandlers: [CalendarSyncer]
    
    private var activeFocusModeTimers: [String: Timer] = [:]
    
    static let shared = SyncOrchestrator(userPreferences: UserPreferences.shared, syncHandlers: [
        NativeCalendarSync()
    ])
    
    
    init(userPreferences: UserPreferences, syncHandlers: [CalendarSyncer]) {
        self.events = []
        self.userPreferences = userPreferences
        self.calendarSyncHandlers = syncHandlers
    }
    
    @MainActor
    func go() {
        Task {
            let events = await syncCalendarEvents()
            
            AppState.shared.calendarEvents = events
        }
    }
    
    func syncCalendarEvents() async -> [CalendarEvent] {
        // Run handlers concurrently
        await withTaskGroup(of: [CalendarEvent].self) { group in
            for handler in calendarSyncHandlers {
                group.addTask {
                    await handler.sync(syncFilter: defaultSyncFilter)
                }
            }
            
            for await events in group {
                self.events.append(contentsOf: events)
            }
        }
                
        // Schedule focus mode activation for each event
        for event in events {
            scheduleFocusModeActivation(event: event)
        }
        
        return events
    }
    
    func scheduleFocusModeActivation(event: CalendarEvent) {
        // Schedules focus mode activation for a particular time
        let eventStartDate = event.startDate
        let eventDuration = Int(event.endDate.timeIntervalSince(eventStartDate))
        
        let timeBuffer = userPreferences.selectedPriorTimeBuffer
        let triggerDelta = timeBuffer * -1
        
        let triggerDate = eventStartDate.addingTimeInterval(TimeInterval(triggerDelta))
             
        // Check if there's an active timer for this event
        if let activeTimer = self.activeFocusModeTimers[event.id] {
            // Cancel it if duration and start date different
            if activeTimer.fireDate != triggerDate {
                activeTimer.invalidate()
            } else {
                // Otherwise, do nothing
                return
            }
        }
        
        let timer = Timer.scheduledTimer(withTimeInterval: triggerDate.timeIntervalSinceNow, repeats: false,
            block: { _ in
                enableFocusMode(duration: eventDuration)
            }
        )
        self.activeFocusModeTimers[event.id] = timer
    }
}
