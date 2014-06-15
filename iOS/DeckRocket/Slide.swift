//
//  Slide.swift
//  DeckRocket
//
//  Created by JP Simard on 6/15/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation

class Slide {
    var image: UIImage
    var markdown: String?
    var body: String?
    var notes: String?
    
    init(image: UIImage, markdown: String?) {
        self.image = image
        if markdown != nil {
            self.markdown = markdown
            body = bodyFromMarkdown()
            notes = notesFromMarkdown()
        }
    }
    
    // String Parsing
    
    func bodyFromMarkdown() -> String {
        // Skip the trailing \n
        let bodyRange = NSRange(location: 0, length: notesStart() - 1)
        return (markdown! as NSString).substringWithRange(bodyRange)
    }
    
    func notesFromMarkdown() -> String? {
        let nsMarkdown = markdown! as NSString
        
        var start = notesStart()
        if start == nsMarkdown.length {
            // No notes
            return nil
        }
        
        // Skip the leading ^
        start++
        let length = nsMarkdown.length - start
        
        let notesRange = NSRange(location: start, length: length)
        return nsMarkdown.substringWithRange(notesRange)
    }
    
    func notesStart() -> Int {
        // Pattern must match http://www.decksetapp.com/support/#how-do-i-add-presenter-notes
        let pattern = "^\\^" // ^\^
        let notesExpression = NSRegularExpression.regularExpressionWithPattern(pattern,
            options: NSRegularExpressionOptions.AnchorsMatchLines,
            error: nil)
        
        let fullRange = NSRange(location: 0, length: (markdown! as NSString).length)
        let notesMatch = notesExpression.firstMatchInString(markdown!, options: NSMatchingOptions(0), range: fullRange)
        if notesMatch {
            return notesMatch.range.location
        }
        return fullRange.length
    }
}
