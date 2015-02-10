//
//  Slide.swift
//  DeckRocket
//
//  Created by JP Simard on 6/15/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import UIKit

struct Slide {

    // MARK: Properties

    let image: UIImage
    let markdown: String?
    let body: String?
    let notes: String?

    // MARK: Initializers

    init(image: UIImage, markdown: String?) {
        self.image = image
        self.markdown = markdown
        body = Slide.bodyFromMarkdown(markdown)
        notes = Slide.notesFromMarkdown(markdown)
    }

    // MARK: String Parsing

    private static func bodyFromMarkdown(markdown: NSString?) -> String? {
        // Skip the trailing \n
        return markdown?.substringWithRange(NSRange(location: 0, length: notesStart(markdown!) - 1)) // Safe to force unwrap
    }

    private static func notesFromMarkdown(markdown: NSString?) -> String? {
        if let markdown = markdown {
            let start = notesStart(markdown)
            if start == markdown.length {
                return nil // No notes
            }
            // Skip the leading ^
            let startWithOutLeadingCaret = start + 1
            let length = markdown.length - startWithOutLeadingCaret
            let notesRange = NSRange(location: startWithOutLeadingCaret, length: length)
            return markdown.substringWithRange(notesRange)
        }
        return nil
    }

    private static func notesStart(markdown: NSString) -> Int {
        // Pattern must match http://www.decksetapp.com/support/#how-do-i-add-presenter-notes
        let pattern = "^\\^" // ^\^
        let notesExpression = NSRegularExpression(pattern: pattern,
            options: .AnchorsMatchLines,
            error: nil)

        let fullRange = NSRange(location: 0, length: markdown.length)
        return notesExpression?
            .firstMatchInString(markdown as! String, options: nil, range: fullRange)?.range.location // Safe to force unwrap
            ?? fullRange.length
    }
}
