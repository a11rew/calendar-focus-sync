import AppIntents
import SwiftUI

let SHORTCUT_NAME = "calendar-focus-sync"
let MISSING_SHORTCUT_MESSAGE = "Could not find Shortcut file. Your installation may be damaged. Reinstall Calendar Focus Sync"

func getInstalledShortcuts() -> [String] {
    let shortcuts = runShellCommand("shortcuts list")
    
    return shortcuts.components(separatedBy: "\n")
}

func isShortcutInstalled() -> Bool {
    let installedShortcuts = getInstalledShortcuts()
    
    return installedShortcuts.contains(SHORTCUT_NAME)
}


func installCFSShortcut() {
    guard let pathToShortcut = Bundle.main.url(forResource: SHORTCUT_NAME, withExtension: "shortcut") else {
        print(MISSING_SHORTCUT_MESSAGE) // TODO: Alert user
        return
    }
    
    runShellCommand("open \(pathToShortcut)")
    
    AppState.shared.isShortCutInstalled = true
}

func runCFSShortcut(_ args: String) {
    guard isShortcutInstalled() else {
        print(MISSING_SHORTCUT_MESSAGE) // TODO: Alert user
        return
    }

    runShellCommand("echo \(args) | shortcuts run \(SHORTCUT_NAME)")
}


func enableFocusMode(duration: Int, focusMode: String? = "Do Not Disturb") {
    runCFSShortcut(String(duration))
}

func deactivateFocusMode(focusMode: String? = "Do Not Disturb") {
    runCFSShortcut("off")
}
