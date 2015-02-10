//
//  PDFImages.swift
//  DeckRocket
//
//  Created by JP Simard on 6/14/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

extension UIImage {
    static func imagesFromPDFPath(pdfPath: String) -> [UIImage] {
        if let pdfURL = NSURL(fileURLWithPath: pdfPath) {
            let pdf = CGPDFDocumentCreateWithURL(pdfURL)
            let numberOfPages = CGPDFDocumentGetNumberOfPages(pdf)

            if numberOfPages == 0 {
                return []
            }

            var images = [UIImage]()
            if let screenSize = UIApplication.sharedApplication().delegate?.window??.bounds.size {
                let largestDimension = max(screenSize.width, screenSize.height)
                let largestSize = CGSize(width: largestDimension, height: largestDimension)

                for pageNumber in 1...numberOfPages {
                    if let image = UIImage(pdfURL: pdfURL, page: pageNumber, fitSize: largestSize) {
                        images.append(image)
                    }
                }
            }
            return images
        }
        return []
    }

    private static func pdfRectForURL(url: NSURL, page: UInt) -> CGRect {
        let pdf = CGPDFDocumentCreateWithURL(url)
        let pageRef = CGPDFDocumentGetPage(pdf, page)
        return CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox)
    }

    convenience init?(pdfURL: NSURL, page: UInt, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)

        let ctx = UIGraphicsGetCurrentContext()

        // From http://www.cocoanetics.com/2010/06/rendering-pdf-is-easier-than-you-thought
        CGContextGetCTM(ctx)
        CGContextScaleCTM(ctx, 1, -1)
        CGContextTranslateCTM(ctx, 0, -size.height)

        let pdf = CGPDFDocumentCreateWithURL(pdfURL)
        let pageRef = CGPDFDocumentGetPage(pdf, page)
        let rect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox)

        CGContextScaleCTM(ctx, size.width / rect.size.width, size.height / rect.size.height)
        CGContextTranslateCTM(ctx, -rect.origin.x, -rect.origin.y)
        CGContextDrawPDFPage(ctx, pageRef)

        let pdfImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.init(CGImage: pdfImage.CGImage)
    }

    convenience init?(pdfURL: NSURL, page: UInt, fitSize size: CGSize) {
        let rect = UIImage.pdfRectForURL(pdfURL, page: page)
        let scaleFactor = max(rect.size.width / size.width, rect.size.height / size.height)
        let newWidth = ceil(rect.size.width / scaleFactor)
        let newHeight = ceil(rect.size.height / scaleFactor)
        let newSize = CGSize(width: newWidth, height: newHeight)
        self.init(pdfURL: pdfURL, page: page, size: newSize)
    }
}
