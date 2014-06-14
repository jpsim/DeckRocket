//
//  AppDelegate.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Cocoa
import MultipeerConnectivity

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Properties
    let multipeerClient = MultipeerClient()
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(CGFloat(NSVariableStatusItemLength))
    
    // App
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        setupMenu()
        multipeerClient.onStateChange = {(state: MCSessionState) -> () in
            var stateString = ""
            switch state {
                case .NotConnected:
                    stateString = "Not Connected"
                case .Connecting:
                    stateString = "Connecting"
                case .Connected:
                    stateString = "Connected"
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.statusItem.menu.itemAtIndex(0).title = stateString
            })
        }
    }
    
    func setupMenu() {
        statusItem.title = "🚀"
        statusItem.highlightMode = true
        let menu = NSMenu()
        menu.addItemWithTitle("Not Connected", action: nil, keyEquivalent: "")
        let item = menu.itemAtIndex(0)
        item.enabled = false
        menu.addItemWithTitle("Quit DeckRocket", action: "quit", keyEquivalent: "")
        statusItem.menu = menu
    }
    
    func quit() {
        NSApp.terminate(self)
    }
}
