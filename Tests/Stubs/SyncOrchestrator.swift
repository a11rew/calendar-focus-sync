@testable import Calendar_Focus_Sync

class TestableSyncOrchestrator: SyncOrchestrator {
    public var goCalledCompletion: (() -> Void)?

    override func go() async {
        await super.go()
                
        goCalledCompletion?()
    }
}
