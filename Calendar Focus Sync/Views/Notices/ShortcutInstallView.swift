import SwiftUI

struct ShortcutInstallNotice: View {
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 18))
                .padding(.trailing, 4)
            
            Text("Shortcut not installed. This is required for Calendar Focus Sync to work")
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
}
