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
    
    var presentation: Presentation?
    let multipeerClient = MultipeerClient()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    let notesView = UITextView()
    let nextSlideView = UIImageView()
    let infoLabel = UILabel()
    
    // View Lifecycle
    
    init() {
        super.init(collectionViewLayout: CollectionViewLayout())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConnectivityObserver()
        updatePresentation()
    }
    
    // Connectivity Updates
    
    func setupConnectivityObserver() {
        multipeerClient.onStateChange = {(state: MCSessionState, peerID: MCPeerID) -> () in
            dispatch_async(dispatch_get_main_queue(), {
                self.notesView.alpha = 0
                self.nextSlideView.alpha = 0
                switch state {
                    case .NotConnected:
                        if self.multipeerClient.session == nil {
                            self.effectView.alpha = 1
                            self.infoLabel.text = "Not Connected"
                        } else if self.multipeerClient.session!.connectedPeers.count == 0 {
                            self.effectView.alpha = 1
                            self.infoLabel.text = "Not Connected"
                            self.multipeerClient.browser!.invitePeer(peerID, toSession: self.multipeerClient.session, withContext: nil, timeout: 30)
                        }
                    case .Connected:
                        if self.presentation == nil {
                            self.effectView.alpha = 1
                            self.infoLabel.text = "No Presentation Loaded"
                        } else {
                            self.effectView.alpha = 0
                            self.infoLabel.text = ""
                        }
                    case .Connecting:
                        self.effectView.alpha = 1
                        self.infoLabel.text = "Connecting..."
                }
            })
        }
    }
    
    // Presentation Updates
    
    func updatePresentation() {
        if let pdfPath = NSUserDefaults.standardUserDefaults().objectForKey("pdfPath") as? NSString {
            var markdown: String?
            if let mdPath = NSUserDefaults.standardUserDefaults().objectForKey("mdPath") as? NSString {
                markdown = NSString.stringWithContentsOfFile(mdPath) as? String
            }
            presentation = Presentation(pdfPath: pdfPath, markdown: markdown?)
            collectionView.contentOffset.x = 0
            collectionView.reloadData()
        }
        // Force state change block
        multipeerClient.onStateChange!!(state: multipeerClient.state, peerID: MCPeerID())
    }
    
    // UI
    
    func setupUI() {
        setupCollectionView()
        setupEffectView()
        setupInfoLabel()
        setupNotesView()
        setupNextSlideView()
    }
    
    func setupCollectionView() {
        collectionView.registerClass(Cell.self, forCellWithReuseIdentifier: "cell")
        collectionView.pagingEnabled = true
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "longPress:"))
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
    
    func setupInfoLabel() {
        infoLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        infoLabel.text = "Not Connected"
        infoLabel.textColor = UIColor.whiteColor()
        effectView.addSubview(infoLabel)
        
        // Constraints
        let centerX = NSLayoutConstraint(item: infoLabel,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: effectView,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0)
        let centerY = NSLayoutConstraint(item: infoLabel,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: effectView,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: 0)
        effectView.addConstraints([centerX, centerY])
    }
    
    func setupNotesView() {
        notesView.setTranslatesAutoresizingMaskIntoConstraints(false)
        notesView.font = UIFont.systemFontOfSize(30)
        notesView.backgroundColor = UIColor.clearColor()
        notesView.textColor = UIColor.whiteColor()
        notesView.editable = false
        notesView.alpha = 0
        effectView.addSubview(notesView)
        
        let horizontal = NSLayoutConstraint.constraintsWithVisualFormat("|[notesView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["notesView": notesView])
        let vertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[notesView]|", options: NSLayoutFormatOptions(0), metrics: nil, views: ["notesView": notesView])
        effectView.addConstraints(horizontal)
        effectView.addConstraints(vertical)
    }
    
    func setupNextSlideView() {
        nextSlideView.setTranslatesAutoresizingMaskIntoConstraints(false)
        nextSlideView.contentMode = UIViewContentMode.ScaleAspectFit
        effectView.addSubview(nextSlideView)
        
        // Constraints
        let ratio = NSLayoutConstraint(item: nextSlideView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nextSlideView,
            attribute: NSLayoutAttribute.Height,
            multiplier: 16.0/9,
            constant: 0)
        let height = NSLayoutConstraint(item: nextSlideView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.LessThanOrEqual,
            toItem: effectView,
            attribute: NSLayoutAttribute.Height,
            multiplier: 0.5,
            constant: 0)
        let left = NSLayoutConstraint(item: nextSlideView,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: effectView,
            attribute: NSLayoutAttribute.Left,
            multiplier: 1,
            constant: 10)
        let right = NSLayoutConstraint(item: nextSlideView,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal,
            toItem: effectView,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1,
            constant: -10)
        let bottom = NSLayoutConstraint(item: nextSlideView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: effectView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: -10)
        effectView.addConstraints([ratio, height, left, right, bottom])
    }
    
    // Gestures
    
    func refreshConnection() {
        multipeerClient.browser!.stopBrowsingForPeers()
        multipeerClient.browser!.startBrowsingForPeers()
    }
    
    func longPress(sender: UILongPressGestureRecognizer) {
        switch sender.state {
            case .Began:
                showNotes(true)
            default:
                // Don't do anything if the effect view is now being used to show a connectivity message
                if multipeerClient.session!.connectedPeers.count > 0 {
                    showNotes(false)
                }
        }
    }
    
    func showNotes(show: Bool) {
        let currentSlideIndex = Int(currentSlide())
        notesView.text = presentation!.slides[currentSlideIndex].notes
        notesView.alpha = 1
        nextSlideView.alpha = 1
        
        if currentSlideIndex < presentation!.slides.count - 1 {
            nextSlideView.setImage(presentation!.slides[currentSlideIndex+1].image)
        } else {
            nextSlideView.setImage(nil)
        }
        UIView.animateWithDuration(0.25, animations: {
            self.effectView.alpha = CGFloat(show)
        }) { finished in
            self.notesView.alpha = CGFloat(show)
            self.nextSlideView.alpha = CGFloat(show)
        }
    }
    
    // Collection View
    
    override func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        if let presentation = self.presentation {
            return presentation.slides.count
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as Cell
        cell.imageView.setImage(presentation!.slides[indexPath.item].image)
        return cell as UICollectionViewCell
    }
    
    // UIScrollViewDelegate
    
    func currentSlide() -> UInt {
        return UInt(round(CDouble(collectionView.contentOffset.x / collectionView.frame.size.width)))
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
