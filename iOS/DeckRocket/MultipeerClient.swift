//
//  MultipeerClient.swift
//  DeckRocket
//
//  Created by JP Simard on 6/14/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

typealias stateChange = ((state: MCSessionState, peerID: MCPeerID) -> ())?

class MultipeerClient: NSObject, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    
    // Properties
    let localPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
    var browser: MCNearbyServiceBrowser?
    var session: MCSession?
    var onStateChange: stateChange?
    
    init() {
        super.init()
        browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: "deckrocket")
        browser!.delegate = self
        browser!.startBrowsingForPeers()
    }
    
    func send(data: NSData) {
        session!.sendData(data, toPeers: session!.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: nil)
    }
    
    func sendString(string: String) {
        send(string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false))
    }
    
    // MCNearbyServiceBrowserDelegate
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: NSDictionary!) {
        if !session {
            session = MCSession(peer: localPeerID)
            session!.delegate = self
        }
        browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 30)
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        
    }
    
    // MCSessionDelegate
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        if let block = onStateChange! {
            block(state: state, peerID: peerID)
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
}
