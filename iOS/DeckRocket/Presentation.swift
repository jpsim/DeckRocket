//
//  Presentation.swift
//  DeckRocket
//
//  Created by JP Simard on 6/15/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import UIKit

class Presentation {
    var markdown = ""
    var slides = Slide[]()
    
    init(pdfPath: String, markdown: String?) {
        var slideImages = UIImage.imagesFromPDFPath(pdfPath)
        
        var pages = String[]()
        
        if markdown != nil {
            self.markdown = markdown!
            pages = self.pages()
        }
        
        for (index, image) in enumerate(slideImages) {
            var page: String?
            if pages.count > index {
                page = pages[index]
            }
            slides += Slide(image: image, markdown: page?)
        }
    }
    
    // Markdown Parsing
    
    func pages() -> String[] {
        let locations = pageLocations()
        
        var pages = String[]()
        
        for (index, end) in enumerate(locations) {
            var start = 0
            if index > 0 {
                start = locations[index - 1]
            }
            var substring = (markdown as NSString).substringWithRange(NSRange(location: start, length: end-start))
            substring = (substring as NSString).stringByReplacingOccurrencesOfString("---\n", withString: "")
            pages += substring
        }
        
        return pages
    }
    
    func pageLocations() -> Int[] {
        // Pattern must match http://www.decksetapp.com/support/#i-separated-my-content-by-----but-deckset-shows-it-on-one-slide-whats-wrong
        let pattern = "^\\-\\-\\-" // ^\-\-\-
        let pagesExpression = NSRegularExpression.regularExpressionWithPattern(pattern,
            options: NSRegularExpressionOptions.AnchorsMatchLines,
            error: nil)
        
        var pageDelimiters = Int[]()
        
        let range = NSRange(location: 0, length: (markdown as NSString).length)
        if let matches = pagesExpression.matchesInString(markdown, options: NSMatchingOptions(0), range: range) {
            for match: NSTextCheckingResult! in matches {
                pageDelimiters += match.range.location
            }
        }
        
        // EOF is an implicit page delimiter
        pageDelimiters += range.length
        
        return pageDelimiters
    }
}
