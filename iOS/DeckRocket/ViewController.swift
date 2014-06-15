//
//  ViewController.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UICollectionViewController, UIScrollViewDelegate {
    
    // Properties
    let multipeerClient = MultipeerClient()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    let connectingLabel = UILabel()
    
    var slideImages = UIImage[]()
    
    // View Lifecycle
    
    init() {
        super.init(collectionViewLayout: CollectionViewLayout())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateSlideImages()
        
        setupUI()
        multipeerClient.onStateChange = {(state: MCSessionState, peerID: MCPeerID) -> () in
            dispatch_async(dispatch_get_main_queue(), {switch state {
                case .NotConnected:
                    if self.multipeerClient.session!.connectedPeers.count == 0 {
                        self.effectView.alpha = 1
                        self.connectingLabel.text = "Not Connected"
                        self.multipeerClient.browser!.invitePeer(peerID, toSession: self.multipeerClient.session, withContext: nil, timeout: 30)
                    }
                case .Connected:
                    self.effectView.alpha = 0
                case .Connecting:
                    self.effectView.alpha = 1
                    self.connectingLabel.text = "Connecting..."
                }
            })
        }
    }
    
    // UI
    
    func updateSlideImages() {
        if let pdfPath = NSUserDefaults.standardUserDefaults().objectForKey("pdfPath") as? NSString {
            slideImages = UIImage.imagesFromPDFPath(pdfPath)
        } else {
            slideImages = UIImage.imagesFromPDFName("presentation.pdf")
        }
        collectionView.contentOffset.x = 0
    }
    
    func setupUI() {
        // Collection View
        collectionView.registerClass(Cell.self, forCellWithReuseIdentifier: "cell")
        collectionView.pagingEnabled = true
        
        setupEffectView()
        setupLabel()
    }
    
    func setupEffectView() {
        effectView.setTranslatesAutoresizingMaskIntoConstraints(false)
        effectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "refreshConnection"))
        view.addSubview(effectView)
        
        let horizontal = NSLayoutConstraint.constraintsWithVisualFormat("|[effectView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["effectView": effectView])
        let vertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|[effectView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["effectView": effectView])
        view.addConstraints(horizontal)
        view.addConstraints(vertical)
    }
    
    func setupLabel() {
        connectingLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        connectingLabel.text = "Not Connected"
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
    
    // Refresh Connection
    
    func refreshConnection() {
        multipeerClient.browser!.stopBrowsingForPeers()
        multipeerClient.browser!.startBrowsingForPeers()
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
    
    func currentSlide() -> UInt {
        return UInt(round(CDouble(collectionView.contentOffset.x / collectionView.frame.size.width)))
    }
    
    func currentSlide2() {
        collectionView.contentOffset.x / collectionView.frame.size.width
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView!) {
        multipeerClient.sendString("\(currentSlide())")
    }
    
    // Rotation
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        // Update Layout
        let layout = collectionView.collectionViewLayout as CollectionViewLayout
        layout.invalidateLayout()
        layout.itemSize = CGSize(width: view.bounds.size.height, height: view.bounds.size.width)
        
        // Update Offset
        let targetOffset = CGFloat(self.currentSlide()) * layout.itemSize.width
        
        // We do this half-way through the animation
        let delay = (duration / 2) * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_current_queue()) {
            self.collectionView.contentOffset.x = targetOffset
        }
    }
}
