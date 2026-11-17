import Cocoa

/// The two things the menu does. Shared by the Finder extension and the host app's self-test.
enum Actions {
    static let iTermBundleID = "com.googlecode.iterm2"

    /// Puts the paths on the clipboard, one per line.
    static func copyPaths(_ urls: [URL]) {
        let text = urls.map(\.path).joined(separator: "\n")
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }

    /// Opens each directory in iTerm2, which starts a session already in that directory.
    static func openInITerm(_ directories: [URL], completion: @escaping @Sendable (Error?) -> Void) {
        guard let iTerm = NSWorkspace.shared.urlForApplication(withBundleIdentifier: iTermBundleID) else {
            completion(NSError(domain: "FinderHere", code: 1,
                               userInfo: [NSLocalizedDescriptionKey: "iTerm2 is not installed"]))
            return
        }
        NSWorkspace.shared.open(directories, withApplicationAt: iTerm,
                                configuration: NSWorkspace.OpenConfiguration()) { _, error in
            completion(error)
        }
    }

    /// A folder stays as it is; a file becomes the folder that holds it.
    static func directory(for url: URL) -> URL {
        url.hasDirectoryPath ? url : url.deletingLastPathComponent()
    }
}
