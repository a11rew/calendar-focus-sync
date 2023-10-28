import SwiftUI

struct GrantPermissionsNotice: View {
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 18))
                .padding(.trailing, 4)
            
            Text("Calendar access is required to sync events")
                .padding(.vertical, 6)
            
            Spacer()
            
            Button("Grant Access") {
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
        .padding(8)
        .background(Color.yellow.opacity(0.3))
        .cornerRadius(8)
    }
}
