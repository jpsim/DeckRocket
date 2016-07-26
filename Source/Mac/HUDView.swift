//
//  HUDView.swift
//  DeckRocket
//
//  Created by JP Simard on 6/14/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Cocoa

private let hudWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
    styleMask: NSBorderlessWindowMask,
    backing: .Buffered,
    defer: false)

final class HUDView: NSView {

    override static func initialize() {
        hudWindow.backgroundColor = NSColor.clearColor()
        hudWindow.opaque = false
        hudWindow.makeKeyAndOrderFront(NSApp)
        hudWindow.level = Int(CGWindowLevelForKey(.OverlayWindowLevelKey))
        hudWindow.center()

        DJProgressHUD.setBackgroundAlpha(0, disableActions: false)
    }

    static func show(string: String) {
        DJProgressHUD.showProgress(1, withStatus: string, fromView: hudWindow.contentView)
        let delay = 2 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            HUDView.dismiss()
        }
    }

    static func showProgress(progress: CGFloat, string: String) {
        DJProgressHUD.showProgress(progress, withStatus: string, fromView: hudWindow.contentView)
    }

    static func showWithActivity(string: String) {
        DJProgressHUD.showStatus(string, fromView: hudWindow.contentView)
    }

    static func dismiss() {
        DJProgressHUD.dismiss()
    }
}
