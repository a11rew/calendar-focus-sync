@testable import Calendar_Focus_Sync

class TestableNativeCalendarSync: NativeCalendarSync {
    public var syncCalled = false
    public var syncCalledCompletion: (() -> Void)?
    
    override func sync(syncFilter: SyncFilter, skipPermissionsCheck: Bool = false) async -> [CalendarEvent] {
        syncCalled = true
        
        let result = await super.sync(syncFilter: syncFilter, skipPermissionsCheck: skipPermissionsCheck)

        syncCalledCompletion?()
        
        return result
    }
}
