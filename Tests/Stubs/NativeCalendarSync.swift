@testable import Calendar_Focus_Sync

class TestableNativeCalendarSync: NativeCalendarSync {
    var syncCalled = false
    
    override func sync(syncFilter: SyncFilter) async -> [CalendarEvent] {
        syncCalled = true
        return await super.sync(syncFilter: syncFilter)
    }
}
