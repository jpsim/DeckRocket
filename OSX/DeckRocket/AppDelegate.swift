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
    let menuView = MenuView()
    
    // App
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
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
            dispatch_async(dispatch_get_main_queue()) {
                self.menuView.menu.itemAtIndex(0).title = stateString
            }
        }
    }
    
    // Menu Items
    
    func quit() {
        NSApplication.sharedApplication().terminate(self)
    }
}
