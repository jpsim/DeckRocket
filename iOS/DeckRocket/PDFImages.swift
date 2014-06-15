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
        let numberOfPages = Int(CGPDFDocumentGetNumberOfPages(pdf))
        var images: UIImage[] = []
        
        let screenSize = UIApplication.sharedApplication().delegate.window!.bounds.size
        let largestDimension = max(Float(screenSize.width), Float(screenSize.height))
        let largestSize = CGSize(width: CGFloat(largestDimension), height: CGFloat(largestDimension))
        
        for pageNumber in 1...numberOfPages {
            images += UIImage(PDFURL: pdfURL, fitSize: largestSize, atPage: pageNumber)
        }
        return images
    }
}
