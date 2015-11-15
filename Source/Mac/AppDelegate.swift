//
//  AppDelegate.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import AppKit
import Carbon
import Cocoa
import Foundation
import MultipeerConnectivity

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: Properties

    let multipeerClient = MultipeerClient()
    private let menuView = MenuView()

    // MARK: App

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        registerHotkey()
        multipeerClient.onStateChange = { state in
            let stateString: String
            let sendSlidesEnabled: Bool
            switch state {
                case .NotConnected:
                    stateString = "Not Connected"
                    sendSlidesEnabled = false
                case .Connecting:
                    stateString = "Connecting..."
                    sendSlidesEnabled = false
                case .Connected:
                    stateString = "Connected"
                    sendSlidesEnabled = true
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.menuView.menu?.itemAtIndex(0)?.title = stateString
                self.menuView.menu?.itemAtIndex(1)?.enabled = sendSlidesEnabled
            }
        }
    }

    func registerHotkey() {
        let flags: NSEventModifierFlags = [.CommandKeyMask, .AlternateKeyMask, .ControlKeyMask]
        DDHotKeyCenter.sharedHotKeyCenter().registerHotKeyWithKeyCode(UInt16(kVK_ANSI_P),
            modifierFlags: flags.rawValue,
            target: self,
            action: "hotkeyWithEvent:",
            object: nil)
    }

    func hotkeyWithEvent(hkEvent: NSEvent) {
        sendSlides()
    }

    // MARK: Menu Items

    func quit() {
        NSApplication.sharedApplication().terminate(self)
    }

    func sendSlides() {
        if let scriptingSlides = DecksetApp()?.documents.first?.slides {
            multipeerClient.sendSlides(scriptingSlides)
        }
    }
}
