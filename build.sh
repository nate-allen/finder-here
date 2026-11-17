#!/bin/zsh
# Builds FinderHere.app (a host app plus its Finder Sync extension) and installs it.
#   ./build.sh              build, install to /Applications, enable the extension
#   ./build.sh uninstall    disable the extension and remove the app
set -euo pipefail

here=${0:A:h}
app_name=FinderHere
ext_name=FinderHereSync
ext_id=local.finderhere.sync
install_dir=/Applications
installed=$install_dir/$app_name.app

if [[ ${1:-} == uninstall ]]; then
  pluginkit -e ignore -i $ext_id 2>/dev/null || true
  pluginkit -r "$installed/Contents/PlugIns/$ext_name.appex" 2>/dev/null || true
  rm -rf "$installed"
  echo "Removed $installed"
  exit 0
fi

build=$here/build
app=$build/$app_name.app
ext=$app/Contents/PlugIns/$ext_name.appex
rm -rf "$build"
mkdir -p "$app/Contents/MacOS" "$ext/Contents/MacOS"

target="$(uname -m)-apple-macos13.0"

swiftc -O -target $target -swift-version 5 \
  "$here/Sources/main.swift" "$here/Sources/Actions.swift" \
  -o "$app/Contents/MacOS/$app_name"

# An app extension has no main of its own: Foundation's NSExtensionMain is the entry point.
swiftc -O -target $target -swift-version 5 -parse-as-library -application-extension \
  -module-name $ext_name \
  "$here/Sources/FinderSync.swift" "$here/Sources/Actions.swift" \
  -Xlinker -e -Xlinker _NSExtensionMain \
  -o "$ext/Contents/MacOS/$ext_name"

cp "$here/Resources/App-Info.plist" "$app/Contents/Info.plist"
cp "$here/Resources/Extension-Info.plist" "$ext/Contents/Info.plist"

# Ad-hoc signatures: enough for an extension that only ever runs on this Mac.
codesign --force --sign - --entitlements "$here/Resources/sandbox.entitlements" "$ext"
codesign --force --sign - --entitlements "$here/Resources/sandbox.entitlements" "$app"

pluginkit -e ignore -i $ext_id 2>/dev/null || true
rm -rf "$installed"
cp -R "$app" "$installed"

# Tell Launch Services about the app first, or the extension lookup below finds nothing.
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f -R "$installed"
pluginkit -a "$installed/Contents/PlugIns/$ext_name.appex"
pluginkit -e use -i $ext_id
echo "Installed $installed"
pluginkit -m -v -i $ext_id
