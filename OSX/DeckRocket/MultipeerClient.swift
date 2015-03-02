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
private typealias KVOContext = UInt8
private var progressContext = KVOContext()
private var lastDisplayTime = NSDate()

final class MultipeerClient: NSObject, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {

    // MARK: Properties

    private let localPeerID = MCPeerID(displayName: NSHost.currentHost().localizedName)
    private let advertiser: MCNearbyServiceAdvertiser?
    private var session: MCSession?
    private var pdfProgress: NSProgress?
    var onStateChange: stateChange?

    // MARK: Lifecycle

    override init() {
        advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: nil, serviceType: "deckrocket")
        super.init()
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    // MARK: Send File

    func sendFile(filePath: String) {
        let url = NSURL(fileURLWithPath: filePath)

        if session == nil || session!.connectedPeers.count == 0 { // Safe to force unwrap
            HUDView.show("Error!\niPhone not connected")
            return
        }

        if let peer = session?.connectedPeers[0] as? MCPeerID {
            pdfProgress = session?.sendResourceAtURL(url, withName: filePath.lastPathComponent, toPeer: peer) { error in
                dispatch_async(dispatch_get_main_queue()) {
                    self.pdfProgress?.removeObserver(self, forKeyPath: "fractionCompleted", context: &progressContext)
                    if let errorDescription = error?.localizedDescription {
                        HUDView.show("Error!\n\(errorDescription)")
                    } else {
                        HUDView.show("Success!")
                    }
                }
            }
            pdfProgress?.addObserver(self, forKeyPath: "fractionCompleted", options: .New, context: &progressContext)
        }
    }

    // MARK: MCNearbyServiceAdvertiserDelegate

    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!)  {
        session = MCSession(peer: localPeerID, securityIdentity: nil, encryptionPreference: .None)
        session?.delegate = self
        invitationHandler(true, session)
    }

    // MARK: MCSessionDelegate

    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        onStateChange??(state: state)
    }

    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        if let launchPath = NSBundle.mainBundle().pathForResource("deckrocket", ofType: "scpt"),
            argument = NSString(data: data, encoding: NSUTF8StringEncoding) {
            let task = NSTask()
            task.launchPath = launchPath
            task.arguments = [argument]
            task.launch()
        }
    }

    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {

    }

    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {

    }

    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {

    }

    // MARK: KVO

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
        if context != &progressContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        } else if abs(lastDisplayTime.timeIntervalSinceNow) > 1/60 { // Update HUD at no more than 60fps
            dispatch_sync(dispatch_get_main_queue()) {
                if let progress = change[NSKeyValueChangeNewKey] as? CGFloat {
                    HUDView.showProgress(progress, string: "Sending File to iPhone")
                    lastDisplayTime = NSDate()
                }
            }
        }
    }
}
