//
//  PreviewViewController.swift
//  zxql-preview-extension
//
//  Created by Andrew Dunbar on 29/1/2026.
//

import Cocoa
import Quartz

class PreviewViewController: NSViewController, QLPreviewingController {
    @IBOutlet weak var imageView: NSImageView?

    override var nibName: NSNib.Name? {
        return NSNib.Name("PreviewViewController")
    }

    override func loadView() {
        super.loadView()
    }

    func preparePreviewOfFile(at url: URL) async throws {
        do {
            let data = try Data(contentsOf: url)
            
            // Validate file size
            guard data.count == 49179 else {
                throw NSError(domain: "PreviewViewController", code: -1, 
                             userInfo: [NSLocalizedDescriptionKey: "Invalid .sna file size: \(data.count) bytes"])
            }
            
            // Create bitmap image
            let image = decodeSnapshotData(data)
            
            DispatchQueue.main.async {
                if let imageView = self.imageView {
                    imageView.image = image
                    imageView.imageScaling = .scaleProportionallyUpOrDown
                }
            }
        } catch {
            let errorImage = createErrorImage(with: "Error reading file: \(error.localizedDescription)")
            DispatchQueue.main.async {
                if let imageView = self.imageView {
                    imageView.image = errorImage
                }
            }
        }
    }

    /// Decode SNA snapshot data
    /// Format: Read 3 bytes at a time: x, y, and RGB as 3:3:2 (RRRGGGBB)
    private func decodeSnapshotData(_ data: Data) -> NSImage {
        let width = 256
        let height = 192
        
        // Create bitmap image representation
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 3,
            hasAlpha: false,
            isPlanar: false,
            colorSpaceName: .calibratedRGB,
            bitmapFormat: [],
            bytesPerRow: width * 3,
            bitsPerPixel: 24
        )!
        
        // Initialize with black
        bitmap.bitmapData?.withMemoryRebound(to: UInt8.self, capacity: width * height * 3) { ptr in
            for i in 0..<(width * height * 3) {
                ptr[i] = 0
            }
        }
        
        // Read 3-byte chunks: x, y, rgb332
        let numChunks = data.count / 3
        for i in 0..<numChunks {
            let offset = i * 3
            let x = Int(data[offset])
            let y = Int(data[offset + 1])
            let rgb332 = data[offset + 2]
            
            // Skip invalid coordinates
            guard x < width && y < height else { continue }
            
            // Decode RGB 3:3:2 format
            let r = UInt8((rgb332 & 0xE0) >> 0)      // Top 3 bits
            let g = UInt8((rgb332 & 0x1C) << 3)      // Middle 3 bits
            let b = UInt8((rgb332 & 0x03) << 6)      // Bottom 2 bits
            
            // Set pixel in bitmap
            let pixelOffset = (y * width + x) * 3
            bitmap.bitmapData?.withMemoryRebound(to: UInt8.self, capacity: width * height * 3) { ptr in
                ptr[pixelOffset] = r
                ptr[pixelOffset + 1] = g
                ptr[pixelOffset + 2] = b
            }
        }
        
        let image = NSImage(size: bitmap.size)
        image.addRepresentation(bitmap)
        return image
    }

    /// Create a simple error image with text
    private func createErrorImage(with message: String) -> NSImage {
        let image = NSImage(size: NSSize(width: 256, height: 192))
        image.lockFocus()
        
        NSColor.black.setFill()
        NSRect(x: 0, y: 0, width: 256, height: 192).fill()
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 10, weight: .regular),
            .foregroundColor: NSColor.red,
            .paragraphStyle: style
        ]
        
        let text = NSAttributedString(string: message, attributes: attributes)
        let rect = NSRect(x: 10, y: 80, width: 236, height: 32)
        text.draw(in: rect)
        
        image.unlockFocus()
        return image
    }
}
