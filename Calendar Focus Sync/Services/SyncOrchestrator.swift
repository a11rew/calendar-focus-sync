import EventKit
import Foundation

protocol CalendarSyncer {
    var identifier: String { get }
    
    func sync(syncFilter: SyncFilter) async -> [CalendarEvent]
    func setupPermissions() async -> Bool
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

let SYNC_DAYS_OUT = 3

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
    
    
    init(userPreferences: UserPreferences, syncHandlers: [CalendarSyncer]) {
        self.events = []
        self.userPreferences = userPreferences
        self.calendarSyncHandlers = syncHandlers
    }
    
    func go() {
        Task {
//            await setupPermissions()
            await syncCalendarEvents()
            
            print("Done syncing, events: \(self.events)")
        }
    }
    
    func syncCalendarEvents() async {
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
    }
    
    func setupPermissions() async {
        await withTaskGroup(of: (String, Bool).self) { group in
            for handler in calendarSyncHandlers {
                group.addTask {
                    let isSetup = await handler.setupPermissions()
                    return (handler.identifier, isSetup)
                }
            }
            
            for await (handler, success) in group {
                if !success {
                    print("Failed to setup permissions for calendar sync handler: \(handler)")
                }
            }
        }
    }
    
    func scheduleFocusModeActivation(event: CalendarEvent) {
        // Schedules focus mode activation for a particular time
        let eventStartDate = event.startDate
        let eventDuration = Int(event.endDate.timeIntervalSince(eventStartDate))
        
        let timeBuffer = userPreferences.selectedPriorTimeBuffer
        let triggerDelta = timeBuffer * -1
        
        let triggerDate = eventStartDate.addingTimeInterval(TimeInterval(triggerDelta))
     
        // Schedule timer to be ran
        
        // Check if there's an active timer for this event
        if let activeTimer = activeFocusModeTimers[event.id] {
            // Cancel it if duration and start date different
            
        }

        let timerContext = ["event": event]
        let timer = Timer.scheduledTimer(withTimeInterval: triggerDate.timeIntervalSinceNow, repeats: false,
            block: { _ in
                enableFocusMode(duration: eventDuration)
            }
        )
        
        activeFocusModeTimers[event.id] = timer
    }
}
