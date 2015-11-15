//
//  DecksetWindow.swift
//  DeckRocket
//
//  Created by JP Simard on 4/8/15.
//  Copyright (c) 2015 JP Simard. All rights reserved.
//

struct DecksetWindow {

    // MARK: Properties

    private let sbWindow: AnyObject

    /// The window's `DecksetDocument`.
    var document: DecksetDocument {
        return DecksetDocument(sbDocument: sbWindow.valueForKey("document")!)
    }

    /// The title of the window.
    var name: String {
        // swiftlint:disable force_cast
        return sbWindow.valueForKey("name") as! String
        // swiftlint:enable force_cast
    }

    // swiftlint:disable variable_name
    /// The unique identifier of the window.
    var id: Int {
        // swiftlint:enable variable_name
        // swiftlint:disable force_cast
        return sbWindow.valueForKey("id") as! Int
        // swiftlint:enable force_cast
    }

    /// Set the unique identifier of the window.
    func setID(value: Int) {
        return sbWindow.setValue(value, forKey: "id")
    }

    /// The index of the window, ordered front to back.
    var index: Int {
        // swiftlint:disable force_cast
        return sbWindow.valueForKey("index") as! Int
        // swiftlint:enable force_cast
    }

    /// Set the index of the window, ordered front to back.
    func setIndex(value: Int) {
        return sbWindow.setValue(value, forKey: "index")
    }

    /// The bounding rectangle of the window.
    var bounds: NSRect {
        // swiftlint:disable force_cast
        return sbWindow.valueForKey("bounds") as! NSRect
        // swiftlint:enable force_cast
    }

    /// Set the bounding rectangle of the window.
    func setBounds(value: NSRect) {
        return sbWindow.setValue(NSValue(rect: value), forKey: "bounds")
    }

    /// Does the window have a close button?
    var closeable: Bool {
        // swiftlint:disable force_cast
        return sbWindow.valueForKey("closeable") as! Bool
        // swiftlint:enable force_cast
    }

    /// Does the window have a minimize button?
    var miniaturizable: Bool {
        // swiftlint:disable force_cast
        return sbWindow.valueForKey("miniaturizable") as! Bool
        // swiftlint:enable force_cast
    }

    /// Is the window minimized right now?
    var miniaturized: Bool {
        // swiftlint:disable force_cast
        return sbWindow.valueForKey("miniaturized") as! Bool
        // swiftlint:enable force_cast
    }

    /// Minimize or unminimize the window.
    func setMiniaturized(value: Bool) {
        return sbWindow.setValue(value, forKey: "miniaturized")
    }

    /// Can the window be resized?
    var resizable: Bool {
        // swiftlint:disable force_cast
        return sbWindow.valueForKey("resizable") as! Bool
        // swiftlint:enable force_cast
    }

    /// Is the window visible right now?
    var visible: Bool {
        // swiftlint:disable force_cast
        return sbWindow.valueForKey("visible") as! Bool
        // swiftlint:enable force_cast
    }

    /// Show or hide the window.
    func setVisible(value: Bool) {
        return sbWindow.setValue(value, forKey: "visible")
    }

    /// Does the window have a zoom button?
    var zoomable: Bool {
        // swiftlint:disable force_cast
        return sbWindow.valueForKey("zoomable") as! Bool
        // swiftlint:enable force_cast
    }

    /// Is the window zoomed right now?
    var zoomed: Bool {
        // swiftlint:disable force_cast
        return sbWindow.valueForKey("zoomed") as! Bool
        // swiftlint:enable force_cast
    }

    /// Zoom or unzoom the window.
    func setZoomed(value: Bool) {
        return sbWindow.setValue(value, forKey: "zoomed")
    }

    // MARK: Initializers

    init(sbWindow: AnyObject) {
        self.sbWindow = sbWindow
    }

    // MARK: Functions

    /// Close a document.
    func close() {
        sbWindow.close()
    }
}
