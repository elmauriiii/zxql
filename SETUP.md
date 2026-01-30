# ZXql Setup & Testing

## Build

```bash
xcodebuild build -project zxql-host-app.xcodeproj -scheme zxql-host-app
```

## Test Quick Look

```bash
# Reset Quick Look daemon
qlmanage -r

# Preview a .sna file
qlmanage -p test.SNA

# Or use Finder: spacebar on any .SNA file
```

## File Format

- **Extension**: `.SNA`
- **Size**: 49,179 bytes (fixed)
- **Resolution**: 256×192 pixels
- **Decoder**: ZX Spectrum screen format

## GitHub Setup

Create repo on GitHub, then:

```bash
git remote add origin https://github.com/hippietrail/zxql.git
git push -u origin main
```

## Real Decoder Implementation

Replace `decodeSnapshotData()` in `PreviewViewController.swift` with actual ZX Spectrum snapshot format parsing.
