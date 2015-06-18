//
//  DecksetDocument.swift
//  DeckRocket
//
//  Created by JP Simard on 4/8/15.
//  Copyright (c) 2015 JP Simard. All rights reserved.
//

/// A document.
struct DecksetDocument {

    // MARK: Properties

    private let sbDocument: AnyObject

    /// Slides in the current document.
    var slides: [DecksetSlide] {
        return (sbDocument.valueForKey("slides") as! [AnyObject]).map {
            DecksetSlide(sbSlide: $0)
        }
    }

    /// Its name.
    var name: String {
        return sbDocument.valueForKey("name") as! String
    }

    /// Has it been modified since the last save?
    var modified: Bool {
        return sbDocument.valueForKey("modified") as! Bool
    }

    /// Its location on disk, if it has one.
    var file: NSURL {
        return sbDocument.valueForKey("file") as! NSURL
    }

    /// Position in the source file.
    var position: Int {
        return sbDocument.valueForKey("position") as! Int
    }

    /// Index of the selected slide.
    var slideIndex: Int {
        return sbDocument.valueForKey("slideIndex") as! Int
    }

    /// Set index of the selected slide.
    func setSlideIndex(index: Int) {
        sbDocument.setValue(index, forKey: "slideIndex")
    }

    // MARK: Initializers

    /**
    Create a `DecksetDocument` based on its backing scripting object.
    
    - parameter sbDocument: backing `DecksetDocument` scripting object.
    */
    init(sbDocument: AnyObject) {
        self.sbDocument = sbDocument
    }

    // MARK: Functions

    /// Close a document.
    func close() {
        sbDocument.close()
    }
}
