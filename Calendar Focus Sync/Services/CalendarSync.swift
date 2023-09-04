import EventKit

let store = EKEventStore()

func checkCalendarEventPermissions() -> EKAuthorizationStatus {
    return EKEventStore.authorizationStatus(for: .event)
}

func requestCalendarEventPermissions() {
    // Request access to event store
    store.requestAccess(to: .event, completion: onCalendarEventPermissionsGranted)
}

func onCalendarEventPermissionsGranted(isGranted: Bool, error: Error?) {
    if error != nil {
        print("Error requesting calendar permissions: \(error as Error?)")
        return
    }
    
    if (!isGranted) {
        print("Calendar permissions not granted")
        return
    }
    
    print("Calendar permissions granted")
    
    // TODO: Sync calendar events
}

