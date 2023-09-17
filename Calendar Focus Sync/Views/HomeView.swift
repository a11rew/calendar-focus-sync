import SwiftUI
import EventKit
import LaunchAtLogin

struct HomeView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var appState: AppState
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Automatically enter focus modes when a calendar event begins")
            
            if !appState.isShortCutInstalled {
                shortcutInstallNotice
            }
                        
            calendarConfig
            
            generalConfig
        }
        .padding(16)
    }
    
    @ViewBuilder
    private var calendarConfig: some View {
        VStack(alignment: .leading) {
            Text("Calendars")
            
            VStack {
                HStack {
                    Text("Calendar")
                    Spacer()
                    
                    Button(userPreferences.nativeCalendarAccess == EKAuthorizationStatus.authorized.rawValue
                           ? "Granted" : "Grant Calendar Access"
                    ) {
                        requestNativeCalendarEventPermissions()
                    }
                    .disabled(userPreferences.nativeCalendarAccess == EKAuthorizationStatus.authorized.rawValue)
                }
            }
            .padding(8)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(NSColor.textColor), lineWidth: 0.5)
                    .opacity(0.3)
            )
        }
    }
    
    @ViewBuilder
    private var shortcutInstallNotice: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 18))
                .padding(.trailing, 4)
            
            Text("Shortcut not installed. This is required for Calendar Focus Sync to work.")
                .padding(.vertical, 6)
            
            Spacer()
                
            Button("Install") {
                installCFSShortcut()
            }
        }
        .padding(8)
        .background(Color.yellow.opacity(0.3))
        .cornerRadius(8)
    }
    
    @ViewBuilder
    private var generalConfig: some View {
        VStack(alignment: .leading) {
            Text("Preferences")
            
            VStack {
                HStack {
                    Text("Launch at login")
                    Spacer()
                    LaunchAtLogin.Toggle("").toggleStyle(.switch)
                }
                
                Divider()
                
                HStack {
                    Text("Enter Focus Mode how long before")
                    Spacer()
                    Picker("", selection: $userPreferences.selectedPriorTimeBuffer) {
                        Text("1 minute").tag(TimeBefore.one_minute.rawValue)
                        Text("2 minutes").tag(TimeBefore.two_minutes.rawValue)
                        Text("5 minutes").tag(TimeBefore.five_minutes.rawValue)
                        Text("10 minutes").tag(TimeBefore.ten_minutes.rawValue)
                    }.frame(maxWidth: 140)
                }
            }
            .padding(8)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(NSColor.textColor), lineWidth: 0.5)
                    .opacity(0.3)
            )
        }
    }
}

#if DEBUG
struct HomeViewPreview: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserPreferences())
            .environmentObject(AppState())
    }
}
#endif
