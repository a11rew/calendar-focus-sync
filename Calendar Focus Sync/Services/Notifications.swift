import Foundation
import UserNotifications

let notificationCenter = UNUserNotificationCenter.current()

@discardableResult
func requestNotificationPermissions() async throws -> Bool {
    let status = await notificationCenter.notificationSettings()
    var isGranted = false
    
    switch status.authorizationStatus {
    case .authorized:
        isGranted = true
    default:
        isGranted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
    }
    
    return isGranted
}

func sendFocusBeginningNotification(event: CalendarEvent) {
    let content = UNMutableNotificationContent()
    content.title = "Focus Mode Activated"
    content.body = "Your event \(event.title) is starting soon. Focus up!"
    content.interruptionLevel = .timeSensitive
    
    content.sound = UNNotificationSound.default
    
    let request = UNNotificationRequest(identifier: event.id, content: content, trigger: nil)
    
    notificationCenter.add(request) { error in
        if error != nil {
            print(error as Any)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound, .badge])
    }
}
