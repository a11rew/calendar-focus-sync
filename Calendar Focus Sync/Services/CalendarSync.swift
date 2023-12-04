import EventKit

// Globally accessible event store
var store = EKEventStore()

@discardableResult
func requestNativeCalendarEventPermissions(eventStore: EKStoreProtocol = EKEventStore()) async throws -> Bool {
    let status = type(of: eventStore).authorizationStatus(for: .event)
    var isGranted = false
        
    switch status {
        case .fullAccess:
            isGranted = true
        default:
            isGranted = try await store.requestFullAccessToEvents()
    }

    if isGranted {
        DispatchQueue.main.async {
            UserPreferences.shared.nativeCalendarAccessGranted = true
        }
    }
    
    return isGranted
}

class NativeCalendarSync: CalendarSyncer {
    var identifier = "native-calendar"
        
    func registerForChanges(selector: Selector, target: AnyObject) {
        NotificationCenter.default.addObserver(target, selector: selector, name: .EKEventStoreChanged, object: nil)
    }

    func sync(syncFilter: SyncFilter, skipPermissionsCheck: Bool = false) async -> [CalendarEvent] {
        if (!skipPermissionsCheck) {
            // Check access to event store
            let status = EKEventStore.authorizationStatus(for: .event)
            
            // Silently exit if permissions not granted
            if status != .fullAccess {
                return []
            }
        }
        
        // Declare event fetch parameters
        // TODO: Filter for specific calendars
        let calendars = store.calendars(for: .event)
        
        // Fetch events
        let predicate = store.predicateForEvents(withStart: syncFilter.startDate, end: syncFilter.endDate, calendars: calendars)
        
        let allEvents = store.events(matching: predicate)
        
        // Filter out all-day events
        let events = allEvents.filter{ event in
            let calendar = Calendar.current

            // Check if the event starts at 00:00
            let startComponents = calendar.dateComponents([.hour, .minute], from: event.startDate)
            let isStartMidnight = startComponents.hour == 0 && startComponents.minute == 0
        
            // Check if the event ends at 00:00 the next day
            let endComponents = calendar.dateComponents([.day, .hour, .minute], from: event.endDate)
            let isEndNextDayMidnight = endComponents.hour == 0 && endComponents.minute == 0 && endComponents.day != calendar.component(.day, from: event.startDate)

            return !event.isAllDay && !(isStartMidnight && isEndNextDayMidnight)
        }
        
        return events.map { event in
            CalendarEvent(
                id: uniqueIDForEventInstance(event: event),
                title: event.title,
                startDate: event.startDate,
                endDate: event.endDate
            )
        }
    }
}

func uniqueIDForEventInstance(event: EKEvent) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // ISO 8601 format
    let startDateString = formatter.string(from: event.startDate)
    let endDateString = formatter.string(from: event.endDate)
    return "\(event.eventIdentifier ?? event.calendarItemIdentifier)_\(startDateString)_\(endDateString)"
}
