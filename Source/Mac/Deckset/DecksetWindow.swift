//
//  DecksetWindow.swift
//  DeckRocket
//
//  Created by JP Simard on 4/8/15.
//  Copyright (c) 2015 JP Simard. All rights reserved.
//

struct DecksetWindow {

    // MARK: Properties

    private let sbWindow: NSObject

    /// The window's `DecksetDocument`.
    var document: DecksetDocument {
        return DecksetDocument(sbDocument: sbWindow.value(forKey: "document")! as AnyObject)
    }

    /// The title of the window.
    var name: String {
        return sbWindow.value(forKey: "name") as! String
    }

    /// The unique identifier of the window.
    var id: Int {
        return sbWindow.value(forKey: "id") as! Int
    }

    /// Set the unique identifier of the window.
    func setID(value: Int) {
        return sbWindow.setValue(value, forKey: "id")
    }

    /// The index of the window, ordered front to back.
    var index: Int {
        return sbWindow.value(forKey: "index") as! Int
    }

    /// Set the index of the window, ordered front to back.
    func setIndex(value: Int) {
        return sbWindow.setValue(value, forKey: "index")
    }

    /// The bounding rectangle of the window.
    var bounds: NSRect {
        return sbWindow.value(forKey: "bounds") as! NSRect
    }

    /// Set the bounding rectangle of the window.
    func setBounds(value: NSRect) {
        return sbWindow.setValue(NSValue(rect: value), forKey: "bounds")
    }

    /// Does the window have a close button?
    var closeable: Bool {
        return sbWindow.value(forKey: "closeable") as! Bool
    }

    /// Does the window have a minimize button?
    var miniaturizable: Bool {
        return sbWindow.value(forKey: "miniaturizable") as! Bool
    }

    /// Is the window minimized right now?
    var miniaturized: Bool {
        return sbWindow.value(forKey: "miniaturized") as! Bool
    }

    /// Minimize or unminimize the window.
    func setMiniaturized(value: Bool) {
        return sbWindow.setValue(value, forKey: "miniaturized")
    }

    /// Can the window be resized?
    var resizable: Bool {
        return sbWindow.value(forKey: "resizable") as! Bool
    }

    /// Is the window visible right now?
    var visible: Bool {
        return sbWindow.value(forKey: "visible") as! Bool
    }

    /// Show or hide the window.
    func setVisible(value: Bool) {
        return sbWindow.setValue(value, forKey: "visible")
    }

    /// Does the window have a zoom button?
    var zoomable: Bool {
        return sbWindow.value(forKey: "zoomable") as! Bool
    }

    /// Is the window zoomed right now?
    var zoomed: Bool {
        return sbWindow.value(forKey: "zoomed") as! Bool
    }

    /// Zoom or unzoom the window.
    func setZoomed(value: Bool) {
        return sbWindow.setValue(value, forKey: "zoomed")
    }

    // MARK: Initializers

    init(sbWindow: NSObject) {
        self.sbWindow = sbWindow
    }

    // MARK: Functions

    /// Close a document.
    func close() {
        // TODO: Implement this
        // sbWindow.close()
    }
}
