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

    func applicationDidFinishLaunching(_ notification: Notification) {
        registerHotkey()
        multipeerClient.onStateChange = { state in
            let stateString: String
            let sendSlidesEnabled: Bool
            switch state {
            case .notConnected:
                    stateString = "Not Connected"
                    sendSlidesEnabled = false
            case .connecting:
                    stateString = "Connecting..."
                    sendSlidesEnabled = false
            case .connected:
                    stateString = "Connected"
                    sendSlidesEnabled = true
            @unknown default:
                stateString = "Unknown connection state: \(state)"
                sendSlidesEnabled = false
            }
            DispatchQueue.main.async {
                self.menuView.menu?.item(at: 0)?.title = stateString
                self.menuView.menu?.item(at: 1)?.isEnabled = sendSlidesEnabled
            }
        }
    }

    func registerHotkey() {
        let flags: NSEvent.ModifierFlags = [.command, .option, .control]
        DDHotKeyCenter.shared().registerHotKey(withKeyCode: UInt16(kVK_ANSI_P),
            modifierFlags: flags.rawValue,
            target: self,
            action: #selector(hotkeyWithEvent),
            object: nil)
    }

    @objc func hotkeyWithEvent(hkEvent: NSEvent) {
        sendSlides()
    }

    // MARK: Menu Items

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }

    @objc func sendSlides() {
        if let scriptingSlides = DecksetApp()?.documents.first?.slides {
            multipeerClient.sendSlides(scriptingSlides: scriptingSlides)
        }
    }
}
