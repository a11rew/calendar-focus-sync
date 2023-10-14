import EventKit

let store = EKEventStore()

@discardableResult
func requestNativeCalendarEventPermissions() async throws -> Bool {
    let status = EKEventStore.authorizationStatus(for: .event)
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
    var eventStore: EKEventStore = store
    var identifier = "native-calendar"
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: .EKEventStoreChanged, object: store)
    }
    
    @objc func storeChanged(_ notification: Notification) {
        Task {
            await self.sync(syncFilter: defaultSyncFilter)
        }
    }
    
    func sync(syncFilter: SyncFilter) async -> [CalendarEvent] {
        // Check access to event store
        let status = EKEventStore.authorizationStatus(for: .event)
        
        // Silently exit if permissions not granted
        if status != .fullAccess {
            return []
        }
        
        // Declare event fetch parameters
        // TODO: Filter for specific calendars
        let calendars = store.calendars(for: .event)
        
        // Fetch events
        let predicate = store.predicateForEvents(withStart: syncFilter.startDate, end: syncFilter.endDate, calendars: calendars)
        let events = store.events(matching: predicate)
        
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
