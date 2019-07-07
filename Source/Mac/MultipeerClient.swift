//
//  MultipeerClient.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

typealias stateChange = ((_ state: MCSessionState) -> ())?
private typealias KVOContext = UInt8
private var progressContext = KVOContext()
private var lastDisplayTime = NSDate()

final class MultipeerClient: NSObject, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate {

    // MARK: Properties

    private let localPeerID = MCPeerID(displayName: Host.current().localizedName!)
    private let advertiser: MCNearbyServiceAdvertiser?
    private var session: MCSession?
    private var pdfProgress: Progress?
    var onStateChange: stateChange?

    // MARK: Lifecycle

    override init() {
        advertiser = MCNearbyServiceAdvertiser(peer: localPeerID, discoveryInfo: nil,
                                               serviceType: "deckrocket")
        super.init()
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    // MARK: Send File

    func sendSlides(scriptingSlides: [DecksetSlide]) {
        guard let peer = session?.connectedPeers.first as MCPeerID? else {
            HUDView.show(string: "Error!\nRemote not connected")
            return
        }
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                HUDView.showWithActivity(string: "Exporting slides...")
            }

            let slidesData: Data
            if #available(OSX 10.11, *) {
                slidesData = NSKeyedArchiver.archivedData(withRootObject: scriptingSlides.map {
                    Slide(pdfData: $0.pdfData, notes: $0.notes)!.dictionaryRepresentation!
                })
            } else {
                slidesData = Data()
            }

            DispatchQueue.main.async {
                HUDView.showWithActivity(string: "Sending slides...")
            }
            do {
                try self.session?.send(slidesData, toPeers: [peer], with: .reliable)
                DispatchQueue.main.async {
                    HUDView.show(string: "Success!")
                }
            } catch {
                DispatchQueue.main.async {
                    HUDView.show(string: "Error!\n\(error)")
                }
            }
        }
    }

    // MARK: MCNearbyServiceAdvertiserDelegate

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer
        peerID: MCPeerID, withContext context: Data?,
                          invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        session = MCSession(peer: localPeerID, securityIdentity: nil,
                            encryptionPreference: .required)
        guard let session = session else { return }
        session.delegate = self
        invitationHandler(true, session)
    }

    // MARK: MCSessionDelegate

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        onStateChange??(state)
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let index = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)?.integerValue {
            DecksetApp()?.documents.first?.setSlideIndex(index: index)
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

    // MARK: KVO

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &progressContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        guard let progress = change?[.newKey] as? CGFloat,
            abs(lastDisplayTime.timeIntervalSinceNow) > 1/60 else {
            // Update HUD at no more than 60fps
            return
        }
        DispatchQueue.main.async {
            HUDView.showProgress(progress: progress, string: "Sending File to iPhone")
            lastDisplayTime = NSDate()
        }
    }
}
