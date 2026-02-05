//
//  PreviewViewController.swift
//  zxql-preview-extension
//
//  Created by Andrew Dunbar on 29/1/2026.
//

import Cocoa
import Quartz
import UniformTypeIdentifiers

extension RandomAccessCollection {
    /// Retrieve a single element from a collection by offset (like Rust, Go, etc.)
    /// - Parameter offset: Offset from start of collection
    /// - Returns: Element at that offset
    subscript(o offset: Int) -> Element {
        return self[index(startIndex, offsetBy: offset)]
    }

    /// Retrieve a sub-collection by offset and length (like Rust, Go, etc.)
    /// - Parameter offset: Offset from start of collection
    /// - Parameter length: Number of elements to retrieve
    /// - Returns: Sub-collection (slice) of specified length
    subscript(o offset: Int, l length: Int) -> SubSequence {
        let startIndex = self.index(self.startIndex, offsetBy: offset)
        let endIndex = self.index(startIndex, offsetBy: length)
        return self[startIndex..<endIndex]
    }

    /// Retrieve a sub-collection by start and end offset (like Rust, Go, etc.)
    /// - Parameter offset: Offset from start of collection
    /// - Parameter endOffset: End offset from start of collection
    /// - Returns: Sub-collection (slice) from offset to endOffset
    subscript(o offset: Int, e endOffset: Int) -> SubSequence {
        let startIndex = self.index(self.startIndex, offsetBy: offset)
        let endIndex = self.index(self.startIndex, offsetBy: endOffset)
        return self[startIndex..<endIndex]
    }
}

class PreviewViewController: NSViewController, QLPreviewingController {
    @IBOutlet weak var imageView: NSImageView?

    override var nibName: NSNib.Name? {
        return NSNib.Name("PreviewViewController")
    }

    override func loadView() {
        super.loadView()
    }

    func preparePreviewOfFile(at url: URL) async throws {
        let data = try Data(contentsOf: url)
        
        // Validate file size - silently reject invalid files
        guard data.count == 49179 else {
            throw NSError(domain: "PreviewViewController", code: -1, 
                         userInfo: [NSLocalizedDescriptionKey: "Invalid .sna file size"])
        }
        
        // Create bitmap image
        let image = decodeSnapshotData(data)
        
        DispatchQueue.main.async {
            if let imageView = self.imageView {
                imageView.image = image
                imageView.imageScaling = .scaleProportionallyUpOrDown
            }
        }
    }

        private func decodeSnapshotData(_ data: Data) -> NSImage {
        let width = 256
        let height = 192

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

        let displayStart = 27
        let displayLength = 32 * 192
        let attributeStart = displayStart + displayLength
        let attributeLength = 32 * 24
        
        let displayData = data[o: displayStart, l: displayLength]
        let attributeData = data[o: attributeStart, l: attributeLength]
        
        guard let bitmapPtr = bitmap.bitmapData else { return NSImage() }

        for charY in 0..<24 {
            for charX in 0..<32 {

                let attr = attributeData[o: charY * 32 + charX]

                let ink = attr & 0x07
                let inkB = UInt8(bitPattern: -Int8(ink & 0b001))
                let inkR = UInt8(bitPattern: -Int8(ink & 0b010)>>1)
                let inkG = UInt8(bitPattern: -Int8(ink & 0b100)>>2)

                let paper = (attr>>3) & 0x07
                let paperB = UInt8(bitPattern: -Int8(paper & 0b001))
                let paperR = UInt8(bitPattern: -Int8(paper & 0b010)>>1)
                let paperG = UInt8(bitPattern: -Int8(paper & 0b100)>>2)

                let bright = (attr & 0x40) != 0

                for pixY in 0..<8 {
                    let y = charY * 8 + pixY

                    // Convert linear Y to Spectrum's "venetian blinds" memory layout:
                    // Swap the 3-bit row-within-char and 3-bit char-row fields
                    let specY = (y & 0b11000000) | ((y & 0b00000111) << 3) | ((y & 0b00111000) >> 3)

                    let byte = displayData[o: specY * 32 + charX]
                    
                    let off = y * 256 * 3 + charX * 8 * 3

                    for bit in 0..<8 {
                        var (r, g, b) = ((0b10000000 >> bit) & byte) != 0 ? (inkR, inkG, inkB) : (paperR, paperG, paperB)

                        if !bright {
                            r = (r >> 2) + (r >> 1) + (r >> 3)
                            g = (g >> 2) + (g >> 1) + (g >> 3)
                            b = (b >> 2) + (b >> 1) + (b >> 3)
                        }

                        let pixelOffset = off + bit * 3
                        bitmapPtr[pixelOffset] = r
                        bitmapPtr[pixelOffset + 1] = g
                        bitmapPtr[pixelOffset + 2] = b
                    }
                }
            }
        }
        
        let image = NSImage(size: bitmap.size)
        image.addRepresentation(bitmap)
        return image
    }
}
