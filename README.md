# ZXql Quick Look Extension

macOS Quick Look extension for 48K ZX Spectrum `.SNA` snapshot files.

## Implementation Notes

### File Format

- **Extension**: `.SNA`
- **Size**: 49,179 bytes (fixed)
- **Resolution**: 256×192 pixels
- **Decoder**: ZX Spectrum screen format

### Challenges Overcome

1. **No standard `.SNA` UTType**: Created custom `com.hippietrail.sna` and exported via host app's Info.plist.

### Build & Test

```
xcodebuild build -scheme zxql-host-app
qlmanage -r  #  Reset QuickLook daemon 
qlmanage -p /path/to/file.SNA
```

Or in Finder: Right-click `.SNA` file → Quick Look (spacebar)

### Key Files

* `zxql-preview-extension/PreviewViewController.swift` - Loads & displays SNA as bitmap image
* `zxql-host-app/Info-generated.plist` - Declares custom `com.hippietrail.sna` UTType
* `zxql-preview-extension/Info.plist` - Extension configuration
* `zxql-preview-extension/Base.lproj/PreviewViewController.xib` - Image view UI
