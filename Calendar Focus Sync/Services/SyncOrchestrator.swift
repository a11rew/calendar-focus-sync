import EventKit
import Foundation

protocol CalendarSyncer {
    var identifier: String { get }
    
    func sync(syncFilter: SyncFilter, skipPermissionsCheck: Bool) async -> [CalendarEvent]
    
    func registerForChanges(selector: Selector, target: AnyObject)
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

actor EventsHolder {
    var events: [CalendarEvent] = []
    
    func append(events newEvents: [CalendarEvent]) {
           self.events.append(contentsOf: newEvents)
    }
    
    func get() -> [CalendarEvent] {
        return self.events
    }
    
    func clear() {
        self.events = []
    }

}

class SyncOrchestrator {
    private let eventsHolder = EventsHolder()
    private let userPreferences: UserPreferences
    private let calendarSyncHandlers: [CalendarSyncer]
    
    var skipPermissionsCheck = false
    var activeFocusModeTimers: [String: Timer] = [:]
    
    init(userPreferences: UserPreferences, syncHandlers: [CalendarSyncer], skipPermissionsCheck: Bool = false) {
        self.userPreferences = userPreferences
        self.calendarSyncHandlers = syncHandlers
        self.skipPermissionsCheck = skipPermissionsCheck
        
        // Register for calendar changes
        for handler in calendarSyncHandlers {
            handler.registerForChanges(selector: #selector(triggerSync), target: self)
        }
    }
    
    deinit {
        for (_, timer) in activeFocusModeTimers {
            timer.invalidate()
        }
    }
    
 
    
    @MainActor
    func go() async {
        Task { @MainActor in
            AppState.shared.calendarEvents = await syncCalendarEvents()
        }
    }
    
    @objc func triggerSync() {
        Task {
            await self.go()
        }
    }
    
    func syncCalendarEvents() async -> [CalendarEvent] {
        // Clear existing events
        await eventsHolder.clear()
        
        // Run handlers concurrently
        await withTaskGroup(of: [CalendarEvent].self) { group in
            for handler in calendarSyncHandlers {
                group.addTask {
                    return await handler.sync(syncFilter: defaultSyncFilter, skipPermissionsCheck: self.skipPermissionsCheck)
                }
            }
            
            for await newEvents in group {
                await eventsHolder.append(events: newEvents)
            }
        }
        
        let events = await eventsHolder.get()

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
        let triggerDelta = timeBuffer * 60 * -1 
                
        let triggerDate = eventStartDate.addingTimeInterval(TimeInterval(triggerDelta))
             
        // Check if there's an active timer for this event
        if let activeTimer = self.activeFocusModeTimers[event.id] {
            // Cancel it if duration and start date different
            if activeTimer.fireDate != triggerDate {
                activeTimer.invalidate()
                activeFocusModeTimers.removeValue(forKey: event.id)
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
