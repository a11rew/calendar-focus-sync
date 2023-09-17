import Foundation
import Combine

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isShortCutInstalled: Bool = false
        
    init() {
        self.isShortCutInstalled = isShortcutInstalled()
    }
}
