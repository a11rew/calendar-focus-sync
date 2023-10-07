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


// TODO: Register event store change listener
//    NotificationCenter.default.addObserver(self, selector: Selector("storeChanged:"), name: .EKEventStoreChanged, object: store)
//

class NativeCalendarSync: CalendarSyncer {
    var eventStore: EKEventStore = store
    var identifier = "native-calendar"
    
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
                id: event.eventIdentifier,
                title: event.title,
                startDate: event.startDate,
                endDate: event.endDate
            )
        }
    }
    
    func setupPermissions() async -> Bool {
        do {
            return try await requestNativeCalendarEventPermissions()
        } catch {
            print("Failed to request calendar permissions: \(error)")
        }
        
        return false
    }
}
