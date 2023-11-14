@testable import Calendar_Focus_Sync

class MockUserPreferences: UserPreferences {
    var mockSelectedPriorTimeBuffer: Int = 0

    override var selectedPriorTimeBuffer: Int {
        get { return mockSelectedPriorTimeBuffer }
        set {
            mockSelectedPriorTimeBuffer = newValue
            // In an actual app, we'd save to UserDefaults here,
            // but for the purpose of testing, we don't want to persist anything.
        }
    }

    init(mockSelectedPriorTimeBuffer: Int = 5) {
        self.mockSelectedPriorTimeBuffer = mockSelectedPriorTimeBuffer
        super.init()
        self.nativeCalendarAccessGranted = false // set a default state
    }
}
