import XCTest
@testable import Calendar_Focus_Sync

final class SyncOrchestratorTests: XCTestCase {
    var mockSyncHandler: TestableNativeCalendarSync!
    var mockUserPreferences: MockUserPreferences!
    var syncOrchestrator: TestableSyncOrchestrator!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockSyncHandler = TestableNativeCalendarSync()
        mockUserPreferences = MockUserPreferences()
        store = MockEKEventStore()
        
        syncOrchestrator = TestableSyncOrchestrator(userPreferences: mockUserPreferences, syncHandlers: [mockSyncHandler], skipPermissionsCheck: true)
    }

    override func tearDownWithError() throws {
        // Clean up
        mockSyncHandler = TestableNativeCalendarSync()
        mockUserPreferences = MockUserPreferences()
        
        syncOrchestrator = nil

        try super.tearDownWithError()
    }

    func testSyncOrchestratorCallsSyncOnHandlers() async throws {
        let expectedEvents = [
            MockEKEvent(title: "Test Event 1", startDate: Date(), endDate: Date()),
            MockEKEvent(title: "Test Event 2", startDate: Date(), endDate: Date())
        ]
        store = MockEKEventStore(eventsToReturn: expectedEvents)
        
        let events = await syncOrchestrator.syncCalendarEvents()

        // Verify that the sync handler's sync function was called
        XCTAssertTrue(mockSyncHandler.syncCalled)
        
        // Verify that the correct events were returned
        XCTAssertTrue(events.elementsEqual(expectedEvents, by: { $0.title == $1.title }))
    }

    func testSyncOrchestratorSchedulesFocusModeActivation() async throws {
        // Setup a future event
        let futureDate = Date().addingTimeInterval(60 * 60 * 24) // 1 day in the future
        let event = MockEKEvent(title: "Future Event", startDate: futureDate, endDate: futureDate.addingTimeInterval(60 * 60))
        store = MockEKEventStore(eventsToReturn: [event])
        
        let bufferTime = -15 * 60 // 15 minutes before
        mockUserPreferences.selectedPriorTimeBuffer = bufferTime

        // This will trigger scheduling of focus mode activation
        let events = await syncOrchestrator.syncCalendarEvents()
        
        // Get scheduled event
        let scheduledEvent = events.filter({ $0.title == event.title }).first
        
        // Verify that the event was scheduled
        XCTAssertNotNil(scheduledEvent)
                
        // Verify a timer has been set
        XCTAssertNotNil(syncOrchestrator.activeFocusModeTimers[scheduledEvent!.id])
    }
    
    // Test that focus mode activation is correctly scheduled with respect to the event's start time and user preferences
    func testFocusModeActivationIsScheduledAccordingToUserPreferences() async throws {
        // Setup a future event
        let futureDate = Date().addingTimeInterval(60 * 60 * 24) // 1 day in the future
        let bufferTime = 10  // 10 minutes before
        mockUserPreferences.selectedPriorTimeBuffer = bufferTime
        
        let event = MockEKEvent(title: "Future Event", startDate: futureDate, endDate: futureDate.addingTimeInterval(60 * 60))
        store = MockEKEventStore(eventsToReturn: [event])
        
        // Sync and schedule focus mode
        let events = await syncOrchestrator.syncCalendarEvents()
        
        // Get scheduled event
        let scheduledEvent = events.filter({ $0.title == event.title }).first

        let timer = syncOrchestrator.activeFocusModeTimers[scheduledEvent!.id]
        XCTAssertNotNil(timer)
        
        // Verify that the scheduled time for focus mode activation is correct
        let expectedActivationTime = futureDate.addingTimeInterval(TimeInterval(bufferTime * -60))
        
        XCTAssertEqual(timer!.fireDate.timeIntervalSinceReferenceDate, expectedActivationTime.timeIntervalSinceReferenceDate, accuracy: 1)
    }
    

    // Test that the timers are updated when the store changes
    func testTimersUpdatedWhenChangeNotificationComesThrough() async throws {
        let orchestrator = TestableSyncOrchestrator(userPreferences: mockUserPreferences, syncHandlers: [mockSyncHandler], skipPermissionsCheck: true)
        
        // Setup an event and a mock timer
        let event = MockEKEvent(title: "Event", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60))
        store = MockEKEventStore(eventsToReturn: [event])
                        
        // Sync and schedule focus mode
        let events = await orchestrator.syncCalendarEvents()
        
        // Get scheduled event
        let scheduledEvent = events.filter({ $0.title == event.title }).first
        let initialTimer = orchestrator.activeFocusModeTimers[scheduledEvent!.id]

        XCTAssertNotNil(initialTimer)
        
        // Add a second event to the store
        let updatedEvent = MockEKEvent(title: "Updated Event", startDate: Date(), endDate: Date().addingTimeInterval(60 * 60))
        
        store = MockEKEventStore(eventsToReturn: [event, updatedEvent])

        let expectation = XCTestExpectation(description: "SyncOrchestrator.go() completes - \(UUID().uuidString)")
        orchestrator.goCalledCompletion = {
            return expectation.fulfill()
        }
                        
        // Trigger storeChanged
        NotificationCenter.default.post(name: .EKEventStoreChanged, object: nil)
        
        await fulfillment(of: [expectation], timeout: 10.0)
                
        // Assert two timers are created and active
        let timers = orchestrator.activeFocusModeTimers
                
        // This might seem counter intuitive, the count should be 2 because the first timer should be invalidated and removed
        // In practice that's what will happen because the id returned from the sync will be the same for both events
        // But in the mock, the id is randomly generated, so the first timer will not be invalidated and removed
        XCTAssertEqual(timers.count, 3)
        
        XCTAssertTrue(timers.values.allSatisfy({ $0.isValid }))
    }
}
