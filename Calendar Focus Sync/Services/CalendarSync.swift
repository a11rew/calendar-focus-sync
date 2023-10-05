import EventKit

let store = EKEventStore()

func requestNativeCalendarEventPermissions() {
    store.requestFullAccessToEvents(completion: { (isGranted: Bool, error: Error?) -> Void in
        if error != nil || !isGranted {
            if let closure = closure {
                closure(false)
            }
        }
        
        DispatchQueue.main.async {
            UserPreferences.shared.nativeCalendarAccess = EKAuthorizationStatus.fullAccess.rawValue
        }
        
        if let closure = closure {
            closure(true)
        }
    })
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
         requestNativeCalendarEventPermissions()
        }
    }
}
