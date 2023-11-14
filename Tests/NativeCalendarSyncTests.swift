import XCTest
import EventKit

@testable import Calendar_Focus_Sync

final class NativeCalendarSyncTests: XCTestCase {
    // Mocked Event Store to return controlled responses for authorization status and request for permissions.
    var mockEventStore = MockEKEventStore()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Replace the global event store instance with the mock
        store = self.mockEventStore
        
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        // Reset the global event store instance
        store = MockEKEventStore()
    }

    func testFullAccessStatusDoesNotRequestPermissions() async throws {
        // Set mock to return .fullAccess
        MockEKEventStore.authorizationStatusToReturn = .fullAccess
        
        let isGranted = try await requestNativeCalendarEventPermissions(eventStore: mockEventStore)

        XCTAssertTrue(isGranted)
        XCTAssertFalse(mockEventStore.didRequestFullAccess) // Ensure requestFullAccessToEvents was not called
    }
    
    func testNonFullAccessStatusRequestsPermissionsAndSucceeds() async throws {
        // Set mock to return .denied and succeed when requesting permissions
        MockEKEventStore.authorizationStatusToReturn = .denied
        mockEventStore.requestFullAccessResult = true

        let isGranted = try await requestNativeCalendarEventPermissions(eventStore: mockEventStore)

        XCTAssertTrue(isGranted)
        XCTAssertTrue(mockEventStore.didRequestFullAccess) // Ensure requestFullAccessToEvents was called
    }
    
    func testNonFullAccessStatusRequestsPermissionsAndFails() async throws {
        // Set mock to return .denied and fail when requesting permissions
        MockEKEventStore.authorizationStatusToReturn = .denied
        mockEventStore.requestFullAccessResult = false
        
        let isGranted = try await requestNativeCalendarEventPermissions(eventStore: mockEventStore)

        XCTAssertFalse(isGranted)
        XCTAssertTrue(mockEventStore.didRequestFullAccess) // Ensure requestFullAccessToEvents was called
    }
    
    func testSyncReturnsEventsWithNewIDs() async throws {
        store = MockEKEventStore(eventsToReturn: [
            MockEKEvent(title: "Test Event 1", startDate: Date(), endDate: Date()),
            MockEKEvent(title: "Test Event 2", startDate: Date(), endDate: Date())
        ])
        
        MockEKEventStore.authorizationStatusToReturn = .fullAccess

        let syncer = TestableNativeCalendarSync()
                                
        let events = await syncer.sync(syncFilter: defaultSyncFilter, skipPermissionsCheck: true)
        
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events.first?.title, "Test Event 1")
        
        // Ensure the IDs are not nil
        XCTAssertNotNil(events.first?.id)
        
        // Ensure the IDs are unique
        XCTAssertNotEqual(events.first?.id, events.last?.id)
    }
}


