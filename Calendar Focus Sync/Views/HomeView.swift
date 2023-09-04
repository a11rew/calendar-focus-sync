import SwiftUI

struct HomeView: View {
    @State private var calendarAccess = checkCalendarEventPermissions()
    @State private var launchOnLogin = true;
    @State private var selectedPriorTimeBuffer: TimeBefore = TimeBefore.one_minute
    
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
                    
                    Button(calendarAccess == .authorized ? "Granted" : "Grant Calendar Access") {
                        // Sync call to request permission
                        requestCalendarEventPermissions()
                    }.disabled(calendarAccess == .authorized)
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
                    Toggle("", isOn: $launchOnLogin)
                        .toggleStyle(.switch)
                }
                
                Divider()
                
                HStack {
                    Text("Enter Focus Mode how long before")
                    Spacer()
                    Picker("", selection: $selectedPriorTimeBuffer) {
                        Text("1 minute").tag(TimeBefore.one_minute)
                        Text("2 minutes").tag(TimeBefore.two_minutes)
                        Text("5 minutes").tag(TimeBefore.five_minutes)
                        Text("10 minutes").tag(TimeBefore.ten_minutes)
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
    }
}
#endif
