//
//  MultipeerClient.swift
//  DeckRocket
//
//  Created by JP Simard on 6/14/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

typealias stateChange = ((_ state: MCSessionState, _ peerID: MCPeerID) -> ())?

final class MultipeerClient: NSObject, MCNearbyServiceBrowserDelegate, MCSessionDelegate {

    // MARK: Properties

    private let localPeerID = MCPeerID(displayName: UIDevice.current.name)
    let browser: MCNearbyServiceBrowser?
    private(set) var session: MCSession?
    private(set) var state = MCSessionState.notConnected
    var onStateChange: stateChange?

    // MARK: Init

    override init() {
        browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: "deckrocket")
        super.init()
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }

    // MARK: Send

    func send(data: NSData) {
        if let session = session {
            try? session.send(data as Data, toPeers: session.connectedPeers, with: .reliable)
        }
    }

    func sendString(string: NSString) {
        if let stringData = string.data(using: String.Encoding.utf8.rawValue) {
            send(data: stringData as NSData)
        }
    }

    // MARK: MCNearbyServiceBrowserDelegate

    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo
                 info: [String : String]?) {
        if session == nil {
            session = MCSession(peer: localPeerID)
            session?.delegate = self
        }
        browser.invitePeer(peerID, to: session!, withContext: nil, timeout: 30)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {

    }

    // MARK: MCSessionDelegate

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        self.state = state
        onStateChange??(state, peerID)
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                .userDomainMask, true)[0] as String
        try? data.write(to: URL(fileURLWithPath: documentsPath).appendingPathComponent("slides"))
        let appDel = UIApplication.shared.delegate
        if let rootVC = appDel?.window??.rootViewController as? ViewController,
            let slides = Slide.slidesfromData(data: data as NSData) {
            rootVC.slides = slides.compactMap { $0 }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream,
                 withName streamName: String, fromPeer peerID: MCPeerID) {
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress) {
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
}
