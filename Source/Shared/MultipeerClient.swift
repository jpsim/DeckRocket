
import Foundation
import MultipeerConnectivity

typealias stateChange = ((state: MCSessionState, peerID: MCPeerID) -> ())?
typealias slidesCallback = (([Slide]) -> ())?

final class MultipeerClient: NSObject, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    
    // MARK: Properties
    
    private let localPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
    let browser: MCNearbyServiceBrowser?
    private(set) var session: MCSession?
    private(set) var state = MCSessionState.NotConnected
    var onStateChange: stateChange?
    var onSlidesReceived: slidesCallback
    
    // MARK: Init
    
    override init() {
        browser = MCNearbyServiceBrowser(peer: localPeerID, serviceType: "deckrocket")
        super.init()
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }
    
    // MARK: Send
    
    func send(data: NSData) {
        session?.sendData(data, toPeers: session!.connectedPeers, withMode: .Reliable, error: nil) // Safe to force unwrap
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
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        data.writeToFile(documentsPath.stringByAppendingPathComponent("slides"), atomically: false)
        if let callback = self.onSlidesReceived,
            data = data,
            slides = Slide.slidesfromData(data) {
                let compactedSlides = compact(slides)
                callback(compactedSlides)
        }
    }
    
    /**
    Slide.slidesfromData(data) {
    rootVC.slides = compact(slides)
    }
    */
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
}