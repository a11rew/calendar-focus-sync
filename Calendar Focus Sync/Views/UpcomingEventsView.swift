import SwiftUI

struct UpcomingEventsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        let events = appState.calendarEvents
            .filter { $0.startDate > Date() }
            .sorted { $0.startDate < $1.startDate }
            .prefix(10)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm, d MMM"
        
        return VStack(alignment: .leading) {
            Text("Upcoming Events")
            
            VStack(alignment: .leading) {
                if events.isEmpty {
                    HStack {
                        Text("No upcoming events")
                        Spacer()
                    }
                } else {
                    ForEach(events, id: \.id) { event in
                        HStack {
                            Text(event.title)
                            
                            Spacer()
                            
                            Text(formatter.string(from: event.startDate))
                        }
                        .padding(.top, 2)
                        
                        if events.last?.id != event.id {
                            Divider()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
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
