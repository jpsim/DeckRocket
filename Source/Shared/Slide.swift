//
//  Slide.swift
//  DeckRocket
//
//  Created by JP Simard on 4/8/15.
//  Copyright (c) 2015 JP Simard. All rights reserved.
//

import CoreGraphics
import Foundation

#if os(OSX)
    import AppKit
    typealias Image = NSImage

    extension NSImage {
        func imageByScalingWithFactor(factor: CGFloat) -> NSImage {
            let targetSize = CGSize(width: size.width * factor, height: size.height * factor)
            let targetRect = NSRect(origin: NSZeroPoint, size: targetSize)
            let newImage = NSImage(size: targetSize)
            newImage.lockFocus()
            drawInRect(targetRect, fromRect: NSZeroRect, operation: .CompositeSourceOver,
                       fraction: 1)
            newImage.unlockFocus()
            return newImage
        }
    }
#else
    import UIKit
    typealias Image = UIImage

    extension UIImage {
        func resizeImage(newSize: CGSize) -> (UIImage) {
            let newRect = CGRectIntegral(CGRect(origin: CGPoint.zero, size: newSize))
            let imageRef = CGImage

            UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
            let context = UIGraphicsGetCurrentContext()

            // Set the quality level to use when rescaling
            CGContextSetInterpolationQuality(context, .High)
            let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)

            CGContextConcatCTM(context, flipVertical)
            // Draw into the context; this scales the image
            CGContextDrawImage(context, newRect, imageRef)

            let newImageRef = CGBitmapContextCreateImage(context)!
            let newImage = UIImage(CGImage: newImageRef)

            // Get the resized image from the context and a UIImage
            UIGraphicsEndImageContext()
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
        guard let image = (dictionary["image"] as? NSData).flatMap({ Image(data: $0) }) else {
            return nil
        }
        self.init(image: image, notes: dictionary["notes"] as? String)
    }

    static func slidesfromData(data: NSData) -> [Slide?]? {
        let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [NSDictionary]
        return dict.flatMap { data in
            data.map {
                guard let imageData = $0["image"] as? NSData, image = Image(data: imageData) else {
                    return nil
                }
                return Slide(image: image, notes: $0["notes"] as? String)
            }
        }
    }

    #if os(OSX)
    init?(pdfData: NSData, notes: String?) {
        guard let pdfImageRep = NSPDFImageRep(data: pdfData) else { return nil }
        let image = NSImage()
        image.addRepresentation(pdfImageRep)
        self.init(image: image.imageByScalingWithFactor(0.5), notes: notes)
    }

    var dictionaryRepresentation: NSDictionary? {
        return image.TIFFRepresentation.flatMap {
            return NSBitmapImageRep(data: $0)?.representationUsingType(.NSJPEGFileType,
                    properties: [NSImageCompressionFactor: 0.5])
        }.flatMap {
            return ["image": $0, "notes": notes ?? ""]
        }
    }
    #else
    var dictionaryRepresentation: NSDictionary? {
        let newSize = CGSize(width: 16 * 2, height: 9 * 2)
        return UIImageJPEGRepresentation(image.resizeImage(newSize), 0.5).flatMap {
            return ["image": $0, "notes": ""]
        }
    }
    #endif
}
