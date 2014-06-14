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
    class func imagesFromPDFName(pdfName: String) -> UIImage[] {
        let path = NSBundle.mainBundle().pathForResource(pdfName, ofType: nil)
        let pdf = CGPDFDocumentCreateWithURL(NSURL(fileURLWithPath: path))
        let numberOfPages = Int(CGPDFDocumentGetNumberOfPages(pdf))
        var images: UIImage[] = []
        
        let screenSize = UIApplication.sharedApplication().delegate.window!.bounds.size
        let largestDimension = max(Float(screenSize.width), Float(screenSize.height))
        let largestSize = CGSize(width: largestDimension, height: largestDimension)
        
        for pageNumber in 1...numberOfPages {
            images += UIImage(PDFNamed: pdfName, fitSize: largestSize, atPage: pageNumber)
        }
        return images
    }
}
