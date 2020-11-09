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
        return (sbDocument.value(forKey: "slides") as! [AnyObject]).map(DecksetSlide.init)
    }

    /// Its name.
    var name: String {
        return sbDocument.value(forKey: "name") as! String
    }

    /// Has it been modified since the last save?
    var modified: Bool {
        return sbDocument.value(forKey: "modified") as! Bool
    }

    /// Its location on disk, if it has one.
    var file: NSURL {
        return sbDocument.value(forKey: "file") as! NSURL
    }

    /// Position in the source file.
    var position: Int {
        return sbDocument.value(forKey: "position") as! Int
    }

    /// Index of the selected slide.
    var slideIndex: Int {
        return sbDocument.value(forKey: "slideIndex") as! Int
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
        // TODO: Implement this
        // sbDocument.close()
    }
}
