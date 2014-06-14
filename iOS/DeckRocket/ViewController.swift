//
//  ViewController.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UICollectionViewController, MCNearbyServiceBrowserDelegate, MCSessionDelegate, UIScrollViewDelegate {
    
    // Properties
    let localPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
    var browser: MCNearbyServiceBrowser?
    var session: MCSession?
    
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    let connectingLabel = UILabel()
    
    var slideImages = UIImage[]()
    
    // View Lifecycle
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 568, height: 320)
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        super.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMultipeer()
        slideImages = imagesFromPDFName("presentation.pdf")
    }
    
    // UI
    
    func setupUI() {
        // Collection View
        collectionView.registerClass(Cell.self, forCellWithReuseIdentifier: "cell")
        collectionView.pagingEnabled = true
        
        // Effect View
        effectView.frame = view.bounds
        view.addSubview(effectView)
        
        setupLabel()
    }
    
    func setupLabel() {
        connectingLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        connectingLabel.text = "Disconnected"
        connectingLabel.textColor = UIColor.whiteColor()
        effectView.addSubview(connectingLabel)
        
        // Constraints
        let centerX = NSLayoutConstraint(item: connectingLabel,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: effectView,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0)
        let centerY = NSLayoutConstraint(item: connectingLabel,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: effectView,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: 0)
        effectView.addConstraints([centerX, centerY])
    }
    
    // PDF Support
    
    func imagesFromPDFName(pdfName: String) -> UIImage[] {
        let path = NSBundle.mainBundle().pathForResource(pdfName, ofType: nil)
        let pdf = CGPDFDocumentCreateWithURL(NSURL(fileURLWithPath: path))
        let numberOfPages = Int(CGPDFDocumentGetNumberOfPages(pdf))
        var images: UIImage[] = []
        for pageNumber in 1...numberOfPages {
            images += UIImage(PDFNamed: pdfName, fitSize: view.bounds.size, atPage: pageNumber)
        }
        return images
    }
    
    // Collection View
    
    override func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return slideImages.count
    }
    
    override func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as Cell
        cell.imageView.setImage(slideImages[indexPath.item])
        return cell as UICollectionViewCell
    }
    
    // UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView!) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        sendString("\(page)")
    }
    
    // Multipeer
    
    func setupMultipeer() {
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
        dispatch_async(dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.5, animations: {
                switch state {
                    case .NotConnected:
                        if session.connectedPeers.count == 0 {
                            self.effectView.alpha = 1
                            self.connectingLabel.text = "Disconnected"
                            self.browser!.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 30)
                        }
                    case .Connected:
                        self.effectView.alpha = 0
                    case .Connecting:
                        self.effectView.alpha = 1
                        self.connectingLabel.text = "Connecting..."
                }
            })
        })
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
