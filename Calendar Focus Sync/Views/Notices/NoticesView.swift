import SwiftUI

struct NoticesView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var userPreferences: UserPreferences
    
    var body: some View {
        if !appState.isShortCutInstalled {
            ShortcutInstallNotice()
        }
        
        if !userPreferences.nativeCalendarAccessGranted {
            GrantPermissionsNotice()
        }
    }
}
