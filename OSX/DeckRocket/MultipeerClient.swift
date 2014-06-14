//
//  MultipeerClient.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

typealias stateChange = ((state: MCSessionState) -> ())?

class MultipeerClient: NSObject, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {
    
    // Properties
    let localPeerID = MCPeerID(displayName: NSHost.currentHost().localizedName)
    var advertiser: MCNearbyServiceAdvertiser?
    var session: MCSession?
    var onStateChange: stateChange?
    
    // Lifecycle
    
    init() {
        super.init()
        advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: nil, serviceType: "deckrocket")
        advertiser!.delegate = self
        advertiser!.startAdvertisingPeer()
    }
    
    // MCNearbyServiceAdvertiserDelegate
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!)  {
        session = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.None)
        session!.delegate = self
        invitationHandler(true, session!)
    }
    
    // MCSessionDelegate
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        if let block = onStateChange! {
            block(state: state)
        }
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
