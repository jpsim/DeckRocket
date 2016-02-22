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
        return sbWindow.valueForKey("name") as! String
    }

    /// The unique identifier of the window.
    var id: Int {
        return sbWindow.valueForKey("id") as! Int
    }

    /// Set the unique identifier of the window.
    func setID(value: Int) {
        return sbWindow.setValue(value, forKey: "id")
    }

    /// The index of the window, ordered front to back.
    var index: Int {
        return sbWindow.valueForKey("index") as! Int
    }

    /// Set the index of the window, ordered front to back.
    func setIndex(value: Int) {
        return sbWindow.setValue(value, forKey: "index")
    }

    /// The bounding rectangle of the window.
    var bounds: NSRect {
        return sbWindow.valueForKey("bounds") as! NSRect
    }

    /// Set the bounding rectangle of the window.
    func setBounds(value: NSRect) {
        return sbWindow.setValue(NSValue(rect: value), forKey: "bounds")
    }

    /// Does the window have a close button?
    var closeable: Bool {
        return sbWindow.valueForKey("closeable") as! Bool
    }

    /// Does the window have a minimize button?
    var miniaturizable: Bool {
        return sbWindow.valueForKey("miniaturizable") as! Bool
    }

    /// Is the window minimized right now?
    var miniaturized: Bool {
        return sbWindow.valueForKey("miniaturized") as! Bool
    }

    /// Minimize or unminimize the window.
    func setMiniaturized(value: Bool) {
        return sbWindow.setValue(value, forKey: "miniaturized")
    }

    /// Can the window be resized?
    var resizable: Bool {
        return sbWindow.valueForKey("resizable") as! Bool
    }

    /// Is the window visible right now?
    var visible: Bool {
        return sbWindow.valueForKey("visible") as! Bool
    }

    /// Show or hide the window.
    func setVisible(value: Bool) {
        return sbWindow.setValue(value, forKey: "visible")
    }

    /// Does the window have a zoom button?
    var zoomable: Bool {
        return sbWindow.valueForKey("zoomable") as! Bool
    }

    /// Is the window zoomed right now?
    var zoomed: Bool {
        return sbWindow.valueForKey("zoomed") as! Bool
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
