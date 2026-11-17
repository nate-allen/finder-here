# FinderHere

Two extra items in Finder's right-click menu on macOS:

- Copy Path
- New iTerm2 Tab Here

I wanted these without installing a big utility app, so this is the smallest thing that does the job. It has no settings and no window, and it stays out of the menu bar.

## What it does

Right-click a file, a folder, or the empty space in a Finder window.

"Copy Path" puts the full path on your clipboard. Select several items and you get one path per line.

"New iTerm2 Tab Here" opens iTerm2 in that folder. If you right-clicked a file, it opens the folder the file is in.

## What you need

- macOS 13 or newer
- Xcode, or Apple's command line tools (`xcode-select --install`)
- [iTerm2](https://iterm2.com), for the terminal item

## Install

Download or clone this repo, then run this from inside the folder:

```
./build.sh
```

That builds the app on your Mac, copies it to `/Applications/FinderHere.app` and switches it on. The two items should appear the next time you right-click in Finder.

If they don't, open FinderHere from your Applications folder. It opens the right page in System Settings, where you can tick the box next to it.

Once it's installed you can delete this folder. The app doesn't need it.

## Uninstall

```
./build.sh uninstall
```

Dragging FinderHere out of Applications and into the Trash works too.

## Good to know

The items might not show up inside iCloud Drive or other cloud-synced folders. That's a limit of how Finder lets apps add to its menu.

After a big macOS update you may have to switch it back on. Open FinderHere and tick the box again.

To rename an item or add your own, edit `Sources/FinderSync.swift` and run `./build.sh` again.
