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
qlmanage -p test.sna

# Or use Finder: spacebar on any .sna file
```

## Create Test .sna Files

Python script to generate test files with demo decoder (3-byte chunks):

```python
import os

filename = "test.sna"
with open(filename, 'wb') as f:
    bytes_written = 0
    target = 49179
    
    while bytes_written < target:
        x = (bytes_written // 3) % 256
        y = ((bytes_written // 3) // 256) % 192
        rgb332 = ((x & 0xE0) | ((y & 0x1C) << 3) | (x & 0x03))
        
        f.write(bytes([x, y, rgb332]))
        bytes_written += 3
    
    remaining = target - bytes_written
    if remaining > 0:
        f.write(b'\x00' * remaining)
```

## File Format

- **Extension**: `.sna`
- **Size**: 49,179 bytes (fixed)
- **Resolution**: 256×192 pixels
- **Demo Decoder**: 3 bytes per pixel → (x, y, RGB 3:3:2)

## GitHub Setup

Create repo on GitHub, then:

```bash
git remote add origin https://github.com/hippietrail/zxql.git
git push -u origin main
```

## Real Decoder Implementation

Replace `decodeSnapshotData()` in `PreviewViewController.swift` with actual ZX Spectrum snapshot format parsing.
