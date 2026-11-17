import Cocoa
import FinderSync

/// Adds "Copy Path" and "New iTerm2 Tab Here" to Finder's right-click menu,
/// both on selected items and on the blank area of a folder window.
@objc(FinderSync)
final class FinderSync: FIFinderSync {
    /// Menu item tags: which thing was right-clicked.
    private enum Target: Int {
        case container  // blank area of a window: act on the folder being shown
        case items      // one or more selected items
    }

    override init() {
        super.init()
        // Offer the menu everywhere, not only inside particular folders.
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        let target: Target
        switch menuKind {
        case .contextualMenuForContainer: target = .container
        case .contextualMenuForItems: target = .items
        default: return nil
        }

        let menu = NSMenu(title: "")
        for (title, action) in [("Copy Path", #selector(copyPath(_:))),
                                ("New iTerm2 Tab Here", #selector(openTerminal(_:)))] {
            let item = menu.addItem(withTitle: title, action: action, keyEquivalent: "")
            item.target = self
            item.tag = target.rawValue
        }
        return menu
    }

    private func urls(for sender: NSMenuItem) -> [URL] {
        let controller = FIFinderSyncController.default()
        if Target(rawValue: sender.tag) == .items, let selected = controller.selectedItemURLs(), !selected.isEmpty {
            return selected
        }
        return controller.targetedURL().map { [$0] } ?? []
    }

    @objc func copyPath(_ sender: NSMenuItem) {
        let urls = urls(for: sender)
        guard !urls.isEmpty else { return }
        Actions.copyPaths(urls)
    }

    @objc func openTerminal(_ sender: NSMenuItem) {
        var seen = Set<String>()
        let directories = urls(for: sender)
            .map(Actions.directory(for:))
            .filter { seen.insert($0.path).inserted }
        guard !directories.isEmpty else { return }
        Actions.openInITerm(directories) { error in
            if let error { NSLog("FinderHere: could not open iTerm2: %@", error.localizedDescription) }
        }
    }
}
