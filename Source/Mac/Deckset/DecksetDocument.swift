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
        // swiftlint:disable force_cast
        return (sbDocument.valueForKey("slides") as! [AnyObject]).map(DecksetSlide.init)
        // swiftlint:enable force_cast
    }

    /// Its name.
    var name: String {
        // swiftlint:disable force_cast
        return sbDocument.valueForKey("name") as! String
        // swiftlint:enable force_cast
    }

    /// Has it been modified since the last save?
    var modified: Bool {
        // swiftlint:disable force_cast
        return sbDocument.valueForKey("modified") as! Bool
        // swiftlint:enable force_cast
    }

    /// Its location on disk, if it has one.
    var file: NSURL {
        // swiftlint:disable force_cast
        return sbDocument.valueForKey("file") as! NSURL
        // swiftlint:enable force_cast
    }

    /// Position in the source file.
    var position: Int {
        // swiftlint:disable force_cast
        return sbDocument.valueForKey("position") as! Int
        // swiftlint:enable force_cast
    }

    /// Index of the selected slide.
    var slideIndex: Int {
        // swiftlint:disable force_cast
        return sbDocument.valueForKey("slideIndex") as! Int
        // swiftlint:enable force_cast
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
