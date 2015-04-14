//
//  Slide.swift
//  DeckRocket
//
//  Created by JP Simard on 4/8/15.
//  Copyright (c) 2015 JP Simard. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
    typealias Image = UIImage
#else
    import AppKit
    typealias Image = NSImage

    extension NSImage {
        func imageByScalingWithFactor(factor: CGFloat) -> NSImage {
            let targetSize = CGSize(width: size.width * factor, height: size.height * factor)
            let targetRect = NSRect(origin: NSZeroPoint, size: targetSize)
            let newImage = NSImage(size: targetSize)
            newImage.lockFocus()
            drawInRect(targetRect, fromRect: NSZeroRect, operation: .CompositeSourceOver, fraction: 1)
            newImage.unlockFocus()
            return newImage
        }
    }
#endif

struct Slide {
    let image: Image
    let notes: String?

    init(image: Image, notes: String?) {
        self.image = image
        self.notes = notes
    }

    init?(dictionary: NSDictionary) {
        let image = flatMap(dictionary["image"] as? NSData) { Image(data: $0) }
        let notes = dictionary["notes"] as? String
        if let image = image {
            self.init(image: image, notes: notes)
            return
        }
        return nil
    }

    static func slidesfromData(data: NSData) -> [Slide?]? {
        return flatMap(NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [NSDictionary]) { data in
            map(data) {
                if let imageData = $0["image"] as? NSData, image = Image(data: imageData) {
                    let notes = $0["notes"] as? String
                    return Slide(image: image, notes: notes)
                }
                return nil
            }
        }
    }

    #if !os(iOS)
    init?(pdfData: NSData, notes: String?) {
        if let pdfImageRep = NSPDFImageRep(data: pdfData) {
            let image = NSImage()
            image.addRepresentation(pdfImageRep)
            self.init(image: image.imageByScalingWithFactor(0.5), notes: notes)
            return
        }
        return nil
    }

    var dictionaryRepresentation: NSDictionary? {
        return flatMap(flatMap(image.TIFFRepresentation) {
            return NSBitmapImageRep(data: $0)?
                .representationUsingType(.NSJPEGFileType, properties: [NSImageCompressionFactor: 0.5])
        }) {
            return ["image": $0, "notes": notes ?? ""]
        }
    }
    #endif
}
