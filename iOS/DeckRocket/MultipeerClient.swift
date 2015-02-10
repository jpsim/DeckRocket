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

final class MultipeerClient: NSObject, MCNearbyServiceBrowserDelegate, MCSessionDelegate {

    // MARK: Properties

    private let localPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
    let browser: MCNearbyServiceBrowser?
    private(set) var session: MCSession?
    private(set) var state = MCSessionState.NotConnected
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
            session.sendData(data, toPeers: session.connectedPeers, withMode: .Reliable, error: nil)
        }
    }

    func sendString(string: NSString) {
        if let stringData = string.dataUsingEncoding(NSUTF8StringEncoding) {
            send(stringData)
        }
    }

    // MARK: MCNearbyServiceBrowserDelegate

    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        if session == nil {
            session = MCSession(peer: localPeerID)
            session?.delegate = self
        }
        browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 30)
    }

    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {

    }

    // MARK: MCSessionDelegate

    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        self.state = state
        onStateChange??(state: state, peerID: peerID)
    }

    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {

    }

    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {

    }

    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {

    }

    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        if error == nil {
            // FIXME: Switch on FileType once it works
            // TODO: File radar for this
            if contains(FileType.extensionsForType(.PDF), resourceName.pathExtension) {
                handlePDF(resourceName, atURL: localURL)
            } else if contains(FileType.extensionsForType(.Markdown), resourceName.pathExtension) {
                handleMarkdown(resourceName, atURL: localURL)
            }
//            if let fileType = FileType(fileExtension: resourceName.pathExtension) {
//                switch fileType {
//                    case .PDF:
//                        handlePDF(resourceName, atURL: localURL)
//                    case .Markdown:
//                        handleMarkdown(resourceName, atURL: localURL)
//                }
//            }
        }
    }

    // MARK: Handle Resources

    private func handlePDF(resourceName: String!, atURL localURL: NSURL!) {
        promptToLoadResource("New Presentation File", resourceName: resourceName, atURL: localURL, userDefaultsKey: "pdfPath")
    }

    private func handleMarkdown(resourceName: String!, atURL localURL: NSURL!) {
        promptToLoadResource("New Markdown File", resourceName: resourceName, atURL: localURL, userDefaultsKey: "mdPath")
    }

    private func promptToLoadResource(title: String, resourceName: String, atURL localURL: NSURL, userDefaultsKey: String) {
        let rootVC = UIApplication.sharedApplication().delegate?.window??.rootViewController as? ViewController

        let alert = UIAlertController(title: title, message: "Would you like to load \"\(resourceName)\"?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Load", style: .Default) { action in
            if let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as? NSString {
                let filePath = documentsPath.stringByAppendingPathComponent(resourceName)

                var error: NSError? = nil
                if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                    NSFileManager.defaultManager().removeItemAtPath(filePath, error: &error)
                }

                if let url = NSURL(fileURLWithPath: filePath) {
                    NSFileManager.defaultManager().moveItemAtURL(localURL, toURL: url, error: &error)
                    if error == nil {
                        NSUserDefaults.standardUserDefaults().setObject(filePath, forKey: userDefaultsKey)
                        NSUserDefaults.standardUserDefaults().synchronize()
                        rootVC?.updatePresentation()
                    }
                }
            }
        })
        dispatch_async(dispatch_get_main_queue()) {
            rootVC?.presentViewController(alert, animated: true, completion: nil)
        }
    }
}
