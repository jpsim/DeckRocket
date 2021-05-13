//
//  DecksetSlide.swift
//  DeckRocket
//
//  Created by JP Simard on 4/8/15.
//  Copyright (c) 2015 JP Simard. All rights reserved.
//

struct DecksetSlide {

    // MARK: Properties

    private let sbSlide: AnyObject

    /// The notes of the text.
    var notes: String {
        return sbSlide.notes
    }

    /// The slide as PDF.
    var pdfData: NSData {
        return sbSlide.pdfData!! as NSData
    }

    // MARK: Initializers

    /**
    Create a `DecksetSlide` based on its backing scripting object.

    - parameter sbSlide: backing `DecksetSlide` scripting object.
    */
    init(sbSlide: AnyObject) {
        self.sbSlide = sbSlide
    }
}
