# ZXql Quick Look Extension

macOS Quick Look extension for `.sna` files (ZX Spectrum 48K snapshots). Right-click any `.sna` file and select "Quick Look" to preview it as a 256×192 bitmap image.

## Implementation Notes

### File Format

- **Extension**: `.sna`
- **Size**: 49,179 bytes (fixed)
- **Resolution**: 256×192 pixels
- **Decoder**: Proper ZX Spectrum 48K bitmap format with attributes

### Challenges Overcome

1. **No standard `.sna` UTType**: Created custom `com.hippietrail.sna` and exported via host app's Info.plist.
2. **Binary image rendering**: Used `NSImage` with `NSBitmapImageRep` for pixel-level control.
3. **Extension sandbox**: Proper file reading within QuickLook sandbox constraints.

### Build & Test

```
xcodebuild build -scheme zxql-host-app
qlmanage -r  #  Reset QuickLook daemon 
qlmanage -p /path/to/file.sna
```

Or in Finder: Right-click `.sna` file → Quick Look (spacebar)

### Key Files

* `zxql-preview-extension/PreviewViewController.swift` - Loads & displays SNA as bitmap image
* `zxql-host-app/Info-generated.plist` - Declares custom `com.hippietrail.sna` UTType
* `zxql-preview-extension/Info.plist` - Extension configuration
* `zxql-preview-extension/Base.lproj/PreviewViewController.xib` - Image view UI
