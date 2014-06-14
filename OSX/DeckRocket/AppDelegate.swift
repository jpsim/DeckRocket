//
//  AppDelegate.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Cocoa
import MultipeerConnectivity

class AppDelegate: NSObject, NSApplicationDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    // Properties
    let localPeerID = MCPeerID(displayName: NSHost.currentHost().localizedName)
    var advertiser: MCNearbyServiceAdvertiser?
    var session: MCSession?
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(CGFloat(NSVariableStatusItemLength))
    
    // App
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        setupMenu()
        setupMultipeer()
    }
    
    func setupMenu() {
        statusItem!.title = "🚀"
        statusItem!.highlightMode = true
        let menu = NSMenu()
        menu.addItemWithTitle("Quit DeckRocket", action: "quit", keyEquivalent: "")
        statusItem!.menu = menu
    }
    
    func setupMultipeer() {
        self.advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: nil, serviceType: "deckrocket")
        self.advertiser!.delegate = self
        self.advertiser!.startAdvertisingPeer()
    }
    
    func quit() {
        NSApp.terminate(nil)
    }
    
    // MARK: MCNearbyServiceAdvertiserDelegate
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!)  {
        self.session = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.None)
        self.session!.delegate = self
        invitationHandler(true, self.session!)
    }
    
    // MARK: MCSessionDelegate
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        let task = NSTask()
        task.launchPath = NSBundle.mainBundle().pathForResource("deckrocket", ofType: "scpt")
        task.arguments = [NSString(data: data, encoding: NSUTF8StringEncoding)]
        task.launch()
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
}
