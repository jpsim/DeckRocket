//
//  MenuView.swift
//  DeckRocket
//
//  Created by JP Simard on 6/14/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Cocoa

class MenuView: NSView, NSMenuDelegate {
    var highlight = false

    // NSVariableStatusItemLength == -1
    // Not using symbol because it doesn't link properly in 10.10
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)

    override init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 24, height: 24))
        registerForDraggedTypes([NSFilenamesPboardType])
        statusItem.view = self
        setupMenu()
    }

    required convenience init(coder: NSCoder) {
        self.init()
    }
    
    // Menu
    
    func setupMenu() {
        let menu = NSMenu()
        menu.addItemWithTitle("Not Connected", action: nil, keyEquivalent: "")
        menu.itemAtIndex(0).enabled = false
        menu.addItemWithTitle("Quit DeckRocket", action: "quit", keyEquivalent: "")
        self.menu = menu
        self.menu.delegate = self
    }
    
    override func mouseDown(theEvent: NSEvent!) {
        super.mouseDown(theEvent)
        statusItem.popUpStatusItemMenu(menu)
    }

    func menuWillOpen(menu: NSMenu!) {
        highlight = true
        needsDisplay = true
    }

    func menuDidClose(menu: NSMenu!) {
        highlight = false
        needsDisplay = true
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        statusItem.drawStatusBarBackgroundInRect(dirtyRect, withHighlight: highlight)
        "🚀".drawInRect(CGRectOffset(dirtyRect, 4, -1), withAttributes: [NSFontAttributeName: NSFont.menuBarFontOfSize(13)])
    }

    // Dragging

    override func draggingEntered(sender: NSDraggingInfo!) -> NSDragOperation {
        return NSDragOperation.Copy
    }

    override func performDragOperation(sender: NSDraggingInfo!) -> Bool {
        let pboard = sender.draggingPasteboard()
        if contains(pboard.types as [NSString], NSFilenamesPboardType) {
            let files = pboard.propertyListForType(NSFilenamesPboardType) as [String]
            let file = files[0]
            if validateFile(file) {
                let appDelegate = NSApplication.sharedApplication().delegate as AppDelegate
                appDelegate.multipeerClient.sendFile(file)
            } else {
                HUDView.show("Error!\nOnly PDF and Markdown files can be sent")
            }
        }
        return true
    }

    func validateFile(filePath: NSString) -> Bool {
        var allowedExtensions = [
            // Markdown
            "markdown", "mdown", "mkdn", "md", "mkd", "mdwn", "mdtxt", "mdtext", "text",
            // PDF
            "pdf"
        ]

        return contains(allowedExtensions, filePath.pathExtension.lowercaseString)
    }
}
