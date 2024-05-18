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
        let uniqueNewEvents = newEvents.filter { newEvent in
            !self.events.contains { existingEvent in
                existingEvent.id == newEvent.id
            }
        }
        
        self.events.append(contentsOf: uniqueNewEvents)
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
    
    static let shared = SyncOrchestrator(userPreferences: UserPreferences.shared, syncHandlers: [NativeCalendarSync()])
    
    var skipPermissionsCheck = false
    var activeFocusModeTimers: [String: Timer] = [:]
    var notificationTimers: [String: Timer] = [:]
    
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
        tearDownTimers()
    }
    
    @MainActor
    func go() async {
        Task { @MainActor in
            AppState.shared.calendarEvents = await syncCalendarEvents()
            AppState.shared.calendars = store.calendars(for: .event)
        }
    }
    
    @objc func triggerSync() {
        Task {
            await self.go()
        }
    }
    
    func tearDownTimers() {
        for (_, timer) in activeFocusModeTimers {
            timer.invalidate()
        }
        
        for (_, notifTimer) in notificationTimers {
            notifTimer.invalidate()
        }
    }
        
    func syncCalendarEvents() async -> [CalendarEvent] {
        // Clear existing events
        await eventsHolder.clear()
        
        // Tear down existing timers
        tearDownTimers()
        
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
        let timeBuffer = userPreferences.selectedPriorTimeBuffer * 60
        
        let eventDuration = (Int(event.endDate.timeIntervalSince(eventStartDate)) + timeBuffer) / 60
        
        let triggerDelta = timeBuffer * -1
         
        let triggerDate = eventStartDate.addingTimeInterval(TimeInterval(triggerDelta))
                
        DispatchQueue.main.sync {
            // Check if there's an active timer for this event
            if let activeTimer = self.activeFocusModeTimers[event.id] {
                activeTimer.invalidate()
                activeFocusModeTimers.removeValue(forKey: event.id)
            }
            
            // Check if there's a notification timer for this event
            if let notificationTimer = self.notificationTimers[event.id] {
                notificationTimer.invalidate()
                notificationTimers.removeValue(forKey: event.id)
            }
            
            // If the event has already started, don't schedule focus mode activation
            if triggerDate.timeIntervalSinceNow < 0 {
                return
            }
            
            // Schedule notification for 1 minute before focus mode activation
            if self.userPreferences.notificationsAccessGranted {
                let notificationTimer = Timer.scheduledTimer(withTimeInterval: triggerDate.timeIntervalSinceNow - 60, repeats: false, block: { _ in
                    sendFocusBeginningNotification(event: event)
                })
                
                self.notificationTimers[event.id] = notificationTimer
            }

            // Schedule focus mode activation
            let timer = Timer.scheduledTimer(withTimeInterval: triggerDate.timeIntervalSinceNow, repeats: false, block: { _ in
                    enableFocusMode(duration: eventDuration)
                }
            )
            
            self.activeFocusModeTimers[event.id] = timer
        }
    }
}
