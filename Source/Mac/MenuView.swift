//
//  MenuView.swift
//  DeckRocket
//
//  Created by JP Simard on 6/14/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Cocoa

final class MenuView: NSView, NSMenuDelegate {
    private var highlight = false

    private let statusItem = NSStatusBar.system
        .statusItem(withLength: NSStatusItem.variableLength)

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
        menu?.addItem(withTitle: "Not Connected", action: nil, keyEquivalent: "")
        menu?.item(at: 0)?.isEnabled = false
        menu?.addItem(withTitle: "Send Slides", action: #selector(AppDelegate.sendSlides), keyEquivalent: "")
        menu?.item(at: 1)?.isEnabled = false
        menu?.addItem(withTitle: "Quit DeckRocket", action: #selector(AppDelegate.quit), keyEquivalent: "")
        menu?.delegate = self
    }

    override func mouseDown(with theEvent: NSEvent) {
        super.mouseDown(with: theEvent)
        if let menu = menu {
            statusItem.popUpMenu(menu)
        }
    }

    func menuWillOpen(_ menu: NSMenu) {
        highlight = true
        needsDisplay = true
    }

    func menuDidClose(_ menu: NSMenu) {
        highlight = false
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        statusItem.drawStatusBarBackground(in: dirtyRect, withHighlight: highlight)
        "🚀".draw(in: dirtyRect.offsetBy(dx: 4, dy: -1),
                    withAttributes: [NSAttributedString.Key.font: NSFont.menuBarFont(ofSize: 14)])
    }
}
