//
//  HUDView.swift
//  DeckRocket
//
//  Created by JP Simard on 6/14/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Cocoa

let hudWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
    styleMask: NSBorderlessWindowMask,
    backing: .Buffered,
    defer: false)

class HUDView: NSView {
    
    override class func initialize() {
        hudWindow.backgroundColor = NSColor.clearColor()
        hudWindow.opaque = false
        hudWindow.makeKeyAndOrderFront(NSApp)
        hudWindow.level = Int(CGWindowLevelForKey(CGWindowLevelKey(kCGOverlayWindowLevelKey)))
        hudWindow.center()
        
        DJProgressHUD.setBackgroundAlpha(0, disableActions: false)
    }
    
    class func show(string: String) {
        DJProgressHUD.showProgress(1, withStatus: string, fromView: hudWindow.contentView as NSView)
        let delay = 2 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_current_queue()) {
            HUDView.dismiss()
        }
    }
    
    class func showProgress(progress: CGFloat, string: String) {
        DJProgressHUD.showProgress(progress, withStatus: string, fromView: hudWindow.contentView as NSView)
    }
    
    class func showWithActivity(string: String) {
        DJProgressHUD.showStatus(string, fromView: hudWindow.contentView as NSView)
    }
    
    class func dismiss() {
        DJProgressHUD.dismiss()
    }
}
