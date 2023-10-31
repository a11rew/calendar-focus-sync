import EventKit
@testable import Calendar_Focus_Sync

class MockEKEventStore: EKEventStore {
    static var authorizationStatusToReturn: EKAuthorizationStatus = .notDetermined
    var requestFullAccessResult: Bool = false
    var didRequestFullAccess: Bool = false
    
    init(requestFullAccessResult: Bool = false) {
        super.init()
        self.requestFullAccessResult = requestFullAccessResult
    }

    override static func authorizationStatus(for entityType: EKEntityType) -> EKAuthorizationStatus {
        return authorizationStatusToReturn
    }

    override func requestFullAccessToEvents() async throws -> Bool {
        didRequestFullAccess = true
        return requestFullAccessResult
    }
}
