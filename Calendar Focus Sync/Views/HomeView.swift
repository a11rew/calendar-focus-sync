import SwiftUI
import EventKit

struct HomeView: View {
    @EnvironmentObject var userPreferences: UserPreferences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Automatically enter focus modes when a calendar event begins")
            
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
                        userPreferences.requestCalendarEventPermissions()
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
    private var generalConfig: some View {
        VStack(alignment: .leading) {
            Text("Preferences")
            
            VStack {
                HStack {
                    Text("Launch at login")
                    Spacer()
                    Toggle("", isOn: $userPreferences.launchOnLogin)
                        .toggleStyle(.switch)
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
    }
}
#endif
