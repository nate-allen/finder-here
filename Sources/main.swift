import Cocoa
import FinderSync

// The app only exists to carry the Finder extension. Launching it opens the
// system's extension settings so the extension can be switched on or off.
//
//   FinderHere --test-open <dir>   runs the iTerm2 action from the same sandbox the extension uses

let arguments = CommandLine.arguments

if arguments.count == 3, arguments[1] == "--test-open" {
    let done = DispatchSemaphore(value: 0)
    Actions.openInITerm([URL(fileURLWithPath: arguments[2], isDirectory: true)]) { error in
        print(error.map { "FAILED: \($0.localizedDescription)" } ?? "OK")
        done.signal()
    }
    done.wait()
    exit(0)
}

FIFinderSyncController.showExtensionManagementInterface()
