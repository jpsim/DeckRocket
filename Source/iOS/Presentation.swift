//
//  Presentation.swift
//  DeckRocket
//
//  Created by JP Simard on 6/15/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import UIKit

struct Presentation {

    // MARK: Properties

    let markdown: String
    let slides: [Slide]

    // MARK: Initializers

    init(pdfPath: String, markdown: String?) {
        let slideImages = UIImage.imagesFromPDFPath(pdfPath)
        let pages = (markdown != nil) ? Presentation.pages(markdown!) : []

        self.markdown = markdown ?? ""
        slides = map(enumerate(slideImages)) { index, image in
            let page: String? = (pages.count > index) ? pages[index] : nil
            return Slide(image: image, markdown: page)
        }
    }

    // MARK: Markdown Parsing

    private static func pages(markdown: NSString) -> [String] {
        let locations = pageLocations(markdown)
        return map(enumerate(locations)) { index, end in
            let start = (index > 0) ? locations[index - 1] : 0
            return markdown.substringWithRange(NSRange(location: start, length: end - start))
                .stringByReplacingOccurrencesOfString("---\n", withString: "")
        }
    }

    private static func pageLocations(markdown: NSString) -> [Int] {
        // Pattern must match http://www.decksetapp.com/support/#i-separated-my-content-by-----but-deckset-shows-it-on-one-slide-whats-wrong
        let pattern = "^\\-\\-\\-" // ^\-\-\-
        let pagesExpression = NSRegularExpression(pattern: pattern,
            options: .AnchorsMatchLines,
            error: nil)

        let range = NSRange(location: 0, length: markdown.length)
        return (pagesExpression?
            .matchesInString(markdown as! String, options: nil, range: range)
            .map {$0.range.location} ?? [])
            + [range.length] // EOF is an implicit page delimiter
    }
}
