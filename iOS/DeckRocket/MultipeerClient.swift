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
    var state = MCSessionState.NotConnected
    var onStateChange: stateChange?
    
    // Init
    
    override init() {
        super.init()
        browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: "deckrocket")
        browser!.delegate = self
        browser!.startBrowsingForPeers()
    }
    
    // Send
    
    func send(data: NSData) {
        session!.sendData(data, toPeers: session!.connectedPeers, withMode: .Reliable, error: nil)
    }
    
    func sendString(string: NSString) {
        send(string.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    // MCNearbyServiceBrowserDelegate
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        if session == nil {
            session = MCSession(peer: localPeerID)
            session!.delegate = self
        }
        browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 30)
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        
    }

    // MCSessionDelegate
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        self.state = state
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
        if error == nil {
            dispatch_async(dispatch_get_main_queue()) {
                let fileType = FileType(fileExtension: resourceName.pathExtension)
                switch fileType {
                case .PDF:
                    self.handlePDF(resourceName, atURL: localURL)
                case .Markdown:
                    self.handleMarkdown(resourceName, atURL: localURL)
                case .Unknown:
                    println("file type unknown")
                }
            }
        }
    }
    
    // Handle Resources
    
    func handlePDF(resourceName: String!, atURL localURL: NSURL!) {
        promptToLoadResource("New Presentation File", resourceName: resourceName, atURL: localURL, userDefaultsKey: "pdfPath")
    }
    
    func handleMarkdown(resourceName: String!, atURL localURL: NSURL!) {
        promptToLoadResource("New Markdown File", resourceName: resourceName, atURL: localURL, userDefaultsKey: "mdPath")
    }
    
    func promptToLoadResource(title: String, resourceName: String, atURL localURL: NSURL, userDefaultsKey: String) {
        let rootVC = UIApplication.sharedApplication().delegate!.window!!.rootViewController as ViewController
        
        let alert = UIAlertController(title: title, message: "Would you like to load \"\(resourceName)\"?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Load", style: .Default) { action in
            var error: NSError? = nil
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
            let filePath = documentsPath.stringByAppendingPathComponent(resourceName)
            
            if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
            }
            
            let url = NSURL(fileURLWithPath: filePath)
            
            NSFileManager.defaultManager().moveItemAtURL(localURL, toURL: url, error: &error)
            if error == nil {
                NSUserDefaults.standardUserDefaults().setObject(filePath, forKey: userDefaultsKey)
                NSUserDefaults.standardUserDefaults().synchronize()
                rootVC.updatePresentation()
            }
        })

        rootVC.presentViewController(alert, animated: true, completion: nil)
    }
}
