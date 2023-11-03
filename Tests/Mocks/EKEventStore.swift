import EventKit
@testable import Calendar_Focus_Sync

struct MockEKEvent {
    var title: String
    var startDate: Date
    var endDate: Date
}

class MockEKEventStore: EKEventStore {
    static var authorizationStatusToReturn: EKAuthorizationStatus = .notDetermined
    var eventsToReturn: [MockEKEvent] = []
    var requestFullAccessResult: Bool = false
    var didRequestFullAccess: Bool = false
    
    init(requestFullAccessResult: Bool = false, eventsToReturn: [MockEKEvent] = []) {
        super.init()
        self.requestFullAccessResult = requestFullAccessResult
        self.eventsToReturn = eventsToReturn
    }

    override static func authorizationStatus(for entityType: EKEntityType) -> EKAuthorizationStatus {
        return authorizationStatusToReturn
    }

    override func requestFullAccessToEvents() async throws -> Bool {
        didRequestFullAccess = true
        return requestFullAccessResult
    }
    
    override func calendars(for entityType: EKEntityType) -> [EKCalendar] {
        return []
    }
    
    override func events(matching predicate: NSPredicate) -> [EKEvent] {
        return eventsToReturn.map { event in
            let mockEvent = EKEvent(eventStore: self)
            mockEvent.title = event.title
            mockEvent.startDate = event.startDate
            mockEvent.endDate = event.endDate
            return mockEvent
        }
    }
}
