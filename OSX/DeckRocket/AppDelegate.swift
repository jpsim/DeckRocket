//
//  AppDelegate.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Properties
    let multipeerClient = MultipeerClient()
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(CGFloat(NSVariableStatusItemLength))
    
    // App
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        setupMenu()
    }
    
    func setupMenu() {
        statusItem.title = "🚀"
        statusItem.highlightMode = true
        let menu = NSMenu()
        menu.addItemWithTitle("Quit DeckRocket", action: "quit", keyEquivalent: "")
        statusItem.menu = menu
    }
    
    func quit() {
        NSApp.terminate(nil)
    }
}
