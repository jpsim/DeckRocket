//
//  AppDelegate.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Cocoa
import MultipeerConnectivity

final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: Properties

    let multipeerClient = MultipeerClient()
    private let menuView = MenuView()

    // MARK: App

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        multipeerClient.onStateChange = { state in
            let stateString: String
            switch state {
                case .NotConnected:
                    stateString = "Not Connected"
                case .Connecting:
                    stateString = "Connecting"
                case .Connected:
                    stateString = "Connected"
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.menuView.menu?.itemAtIndex(0)?.title = stateString
            }
        }
    }

    // MARK: Menu Items

    func quit() {
        NSApplication.sharedApplication().terminate(self)
    }
}
