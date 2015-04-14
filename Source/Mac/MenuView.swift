//
//  MenuView.swift
//  DeckRocket
//
//  Created by JP Simard on 6/14/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Cocoa

// FIXME: Use system-defined constant once accessible from Swift.
let NSVariableStatusItemLength: CGFloat = -1

final class MenuView: NSView, NSMenuDelegate {
    private var highlight = false

    private let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)

    // MARK: Initializers

    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 24, height: 24))
        statusItem.view = self
        setupMenu()
    }

    required convenience init(coder: NSCoder) {
        self.init()
    }

    // MARK: Menu

    private func setupMenu() {
        menu = NSMenu()
        menu?.autoenablesItems = false
        menu?.addItemWithTitle("Not Connected", action: nil, keyEquivalent: "")
        menu?.itemAtIndex(0)?.enabled = false
        menu?.addItemWithTitle("Send Slides", action: "sendSlides", keyEquivalent: "")
        menu?.itemAtIndex(1)?.enabled = false
        menu?.addItemWithTitle("Quit DeckRocket", action: "quit", keyEquivalent: "")
        menu?.delegate = self
    }

    override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
        if let menu = menu {
            statusItem.popUpStatusItemMenu(menu)
        }
    }

    func menuWillOpen(menu: NSMenu) {
        highlight = true
        needsDisplay = true
    }

    func menuDidClose(menu: NSMenu) {
        highlight = false
        needsDisplay = true
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        statusItem.drawStatusBarBackgroundInRect(dirtyRect, withHighlight: highlight)
        "🚀".drawInRect(CGRectOffset(dirtyRect, 4, -1), withAttributes: [NSFontAttributeName: NSFont.menuBarFontOfSize(14)])
    }
}
