// Dependency injection helper for testing
import EventKit

protocol EKStoreProtocol {
    static func authorizationStatus(for entityType: EKEntityType) -> EKAuthorizationStatus
    func requestFullAccessToEvents() async throws -> Bool
}

extension EKEventStore: EKStoreProtocol {
    // Conform EKEventStore to EKStoreProtocol
}
