//
//  HUDView.swift
//  DeckRocket
//
//  Created by JP Simard on 6/14/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Cocoa

private let hudWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 300),
    styleMask: .borderless,
    backing: .buffered,
    defer: false)

final class HUDView: NSView {
    private static var didConfigure = false

    private static func configure() {
        guard !didConfigure else { return }
        didConfigure = true

        hudWindow.backgroundColor = .clear
        hudWindow.isOpaque = false
        hudWindow.makeKeyAndOrderFront(NSApp)
        hudWindow.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.overlayWindow)))
        hudWindow.center()

        DJProgressHUD.setBackgroundAlpha(0, disableActions: false)
    }

    static func show(string: String) {
        configure()
        DJProgressHUD.showProgress(1, withStatus: string, from: hudWindow.contentView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: HUDView.dismiss)
    }

    static func showProgress(progress: CGFloat, string: String) {
        configure()
        DJProgressHUD.showProgress(progress, withStatus: string, from: hudWindow.contentView)
    }

    static func showWithActivity(string: String) {
        configure()
        DJProgressHUD.showStatus(string, from: hudWindow.contentView)
    }

    static func dismiss() {
        configure()
        DJProgressHUD.dismiss()
    }
}
