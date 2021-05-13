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
            draw(in: targetRect, from: NSZeroRect, operation: .sourceOver,
                 fraction: 1)
            newImage.unlockFocus()
            return newImage
        }
    }
#else
    import UIKit
    typealias Image = UIImage

    extension UIImage {
        func resizeImage(newSize: CGSize) -> UIImage {
            let size = self.size
            let widthRatio  = newSize.width  / size.width
            let heightRatio = newSize.height / size.height
            let contextSize: CGSize
            if widthRatio > heightRatio {
                contextSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                contextSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
            }

            let rect = CGRect(origin: .zero, size: contextSize)
            UIGraphicsBeginImageContextWithOptions(contextSize, false, 1.0)
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage!
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
        guard let image = (dictionary["image"] as? NSData).flatMap({ Image(data: $0 as Data) }) else {
            return nil
        }
        self.init(image: image, notes: dictionary["notes"] as? String)
    }

    static func slidesfromData(data: NSData) -> [Slide?]? {
        let dict = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [NSDictionary]
        return dict.flatMap { data in
            data.map {
                guard let imageData = $0["image"] as? Data, let image = Image(data: imageData) else {
                    return nil
                }
                return Slide(image: image, notes: $0["notes"] as? String)
            }
        }
    }

    #if os(OSX)
    init?(pdfData: NSData, notes: String?) {
        guard let pdfImageRep = NSPDFImageRep(data: pdfData as Data) else { return nil }
        let image = NSImage()
        image.addRepresentation(pdfImageRep)
        self.init(image: image.imageByScalingWithFactor(factor: 0.5), notes: notes)
    }

    var dictionaryRepresentation: NSDictionary? {
        return image.tiffRepresentation.flatMap {
            return NSBitmapImageRep(data: $0)?.representation(using: .jpeg,
                    properties: [NSBitmapImageRep.PropertyKey.compressionFactor: 0.5])
        }.flatMap {
            return ["image": $0, "notes": notes ?? ""]
        }
    }
    #else
    var dictionaryRepresentation: NSDictionary? {
        let newSize = CGSize(width: 16 * 2, height: 9 * 2)
        return image.resizeImage(newSize: newSize).jpegData(compressionQuality: 0.5).flatMap {
            return ["image": $0, "notes": ""]
        }
    }
    #endif
}
