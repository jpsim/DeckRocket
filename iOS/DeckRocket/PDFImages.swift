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
    class func imagesFromPDFPath(pdfPath: String) -> UIImage[] {
        let pdfURL = NSURL(fileURLWithPath: pdfPath)
        let pdf = CGPDFDocumentCreateWithURL(pdfURL)
        let numberOfPages = CGPDFDocumentGetNumberOfPages(pdf)
        var images: UIImage[] = []
        
        let screenSize = UIApplication.sharedApplication().delegate.window!.bounds.size
        let largestDimension = max(Float(screenSize.width), Float(screenSize.height))
        let largestSize = CGSize(width: CGFloat(largestDimension), height: CGFloat(largestDimension))
        
        for pageNumber in 1...numberOfPages {
            images += UIImage.imageWithPDFURL(pdfURL, page: pageNumber, fitSize: largestSize)
        }
        return images
    }
    
    class func pdfRectForURL(url: NSURL, page: UInt) -> CGRect {
        let pdf = CGPDFDocumentCreateWithURL(url);
        let pageRef = CGPDFDocumentGetPage(pdf, page);
        
        let rect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox)
        
        return rect
    }
    
    class func imageWithPDFURL(url: NSURL, page: UInt, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        // From http://www.cocoanetics.com/2010/06/rendering-pdf-is-easier-than-you-thought
        CGContextGetCTM(ctx)
        CGContextScaleCTM(ctx, 1, -1)
        CGContextTranslateCTM(ctx, 0, -size.height)
        
        let pdf = CGPDFDocumentCreateWithURL(url)
        
        let pageRef = CGPDFDocumentGetPage(pdf, page)
        
        let rect = CGPDFPageGetBoxRect(pageRef, kCGPDFCropBox)
        
        CGContextScaleCTM(ctx, size.width/rect.size.width, size.height/rect.size.height)
        CGContextTranslateCTM(ctx, -rect.origin.x, -rect.origin.y)
        CGContextDrawPDFPage(ctx, pageRef)
        
        let pdfImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        return pdfImage
    }
    
    class func imageWithPDFURL(url: NSURL, page: UInt, fitSize size: CGSize) -> UIImage {
        let rect = pdfRectForURL(url, page: page)
        let scaleFactor = CGFloat(max(rect.size.width/size.width, rect.size.height/size.height))
        #if arch(x86_64) || arch(arm64)
            var newWidth = ceil(rect.size.width/scaleFactor)
            var newHeight = ceil(rect.size.height/scaleFactor)
            #else
            var newWidth = ceilf(rect.size.width/scaleFactor)
            var newHeight = ceilf(rect.size.height/scaleFactor)
        #endif
        let newSize = CGSize(width: newWidth, height: newHeight);
        return UIImage.imageWithPDFURL(url, page: page, size: newSize)
    }
}
