import SwiftUI
import EventKit
import LaunchAtLogin

struct SettingsView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    @EnvironmentObject var appState: AppState
    
    @State private var isRequestingCalendarPermissions = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Automatically enter focus modes when a calendar event begins")
                
                NoticesView()
                
                CalendarConfigView
                
                GeneralConfigView
                
                UpcomingEventsView()
            }
            .padding(16)
        }
   }
    
    
    @ViewBuilder
    private var CalendarConfigView: some View {
        VStack(alignment: .leading) {
            Text("Calendars")
            
            VStack {
                HStack {
                    Text("Apple Calendar")
                    Spacer()
                    
                    Button(userPreferences.nativeCalendarAccessGranted
                           ? "Granted" : "Grant Calendar Access"
                    ) {
                        requestCalendarPermissions()
                    }
                    .disabled(isRequestingCalendarPermissions || userPreferences.nativeCalendarAccessGranted)
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
    private var GeneralConfigView: some View {
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
    
    func requestCalendarPermissions() {
        Task {
            do {
                try await requestNativeCalendarEventPermissions()
            } catch {
                // TODO: Show error in UI
                print(error)
            }
        }
    }
}

struct SettingsViewPreview: PreviewProvider {
    static var previews: some View {
        let preferences = UserPreferences()
        let appState = AppState()
                    
        SettingsView()
            .environmentObject(preferences)
            .environmentObject(appState)
    }
}
