//
//  ViewController.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import UIKit
import MultipeerConnectivity

let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString

private func userDefaultsString(key: String) -> String? {
    return NSUserDefaults.standardUserDefaults().objectForKey(key) as? NSString as? String
}

private func userDefaultsPathIfFileExists(key: String) -> String? {
    if let name = userDefaultsString(key), let path = Optional(documentsPath.stringByAppendingPathComponent(name)) where NSFileManager.defaultManager().fileExistsAtPath(path) {
        return path
    }
    return nil
}

final class ViewController: UICollectionViewController, UIScrollViewDelegate {

    // MARK: Properties

    private var presentation: Presentation?
    private let multipeerClient = MultipeerClient()
    // UIVisualEffectView's alpha can't be animated, so we nest it in a parent view
    private let effectParentView = UIView()
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    private let notesView = UITextView()
    private let nextSlideView = UIImageView()
    private let infoLabel = UILabel()

    // MARK: View Lifecycle

    init() {
        super.init(collectionViewLayout: CollectionViewLayout())
    }

    convenience required init(coder aDecoder: NSCoder) {
        self.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConnectivityObserver()
        updatePresentation()
    }

    // MARK: Connectivity Updates

    private func setupConnectivityObserver() {
        multipeerClient.onStateChange = { state, peerID in
            dispatch_async(dispatch_get_main_queue(), {
                self.notesView.alpha = 0
                self.nextSlideView.alpha = 0
                switch state {
                    case .NotConnected:
                        if self.multipeerClient.session == nil {
                            self.effectParentView.alpha = 1
                            self.infoLabel.text = "Not Connected"
                        } else if self.multipeerClient.session!.connectedPeers.count == 0 { // Safe to force unwrap
                            self.effectParentView.alpha = 1
                            self.infoLabel.text = "Not Connected"
                            self.multipeerClient.browser?.invitePeer(peerID, toSession: self.multipeerClient.session, withContext: nil, timeout: 30)
                        }
                    case .Connected:
                        if let presentation = self.presentation {
                            self.effectParentView.alpha = 0
                            self.infoLabel.text = ""
                        } else {
                            self.effectParentView.alpha = 1
                            self.infoLabel.text = "No Presentation Loaded"
                        }
                    case .Connecting:
                        self.effectParentView.alpha = 1
                        self.infoLabel.text = "Connecting..."
                }
            })
        }
    }

    // MARK: Presentation Updates

    func updatePresentation() {
        if let pdfPath = userDefaultsPathIfFileExists("pdfName") {
            let markdown: String?
            if let mdPath = userDefaultsPathIfFileExists("mdName") {
                markdown = String(contentsOfFile: mdPath, encoding: NSUTF8StringEncoding)
            } else {
                markdown = nil
            }
            presentation = Presentation(pdfPath: pdfPath, markdown: markdown)
            collectionView?.contentOffset.x = 0
            collectionView?.reloadData()
        }
        // Trigger state change block
        multipeerClient.onStateChange??(state: multipeerClient.state, peerID: MCPeerID())
    }

    // MARK: UI

    private func setupUI() {
        setupCollectionView()
        setupEffectView()
        setupInfoLabel()
        setupNotesView()
        setupNextSlideView()
    }

    private func setupCollectionView() {
        collectionView?.registerClass(Cell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "longPress:"))
        collectionView?.pagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
    }

    private func setupEffectView() {
        effectParentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(effectParentView)

        let horizontal = NSLayoutConstraint.constraintsWithVisualFormat("|[effectParentView]|", options: nil, metrics: nil, views: ["effectParentView": effectParentView])
        let vertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|[effectParentView]|", options: nil, metrics: nil, views: ["effectParentView": effectParentView])
        view.addConstraints(horizontal)
        view.addConstraints(vertical)

        effectView.setTranslatesAutoresizingMaskIntoConstraints(false)
        effectParentView.addSubview(effectView)

        let horizontal2 = NSLayoutConstraint.constraintsWithVisualFormat("|[effectView]|", options: nil, metrics: nil, views: ["effectView": effectView])
        let vertical2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|[effectView]|", options: nil, metrics: nil, views: ["effectView": effectView])
        effectParentView.addConstraints(horizontal2)
        effectParentView.addConstraints(vertical2)
    }

    private func setupInfoLabel() {
        infoLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        infoLabel.text = "Not Connected"
        infoLabel.textColor = UIColor.whiteColor()
        effectView.addSubview(infoLabel)

        // Constraints
        let centerX = NSLayoutConstraint(item: infoLabel,
            attribute: .CenterX,
            relatedBy: .Equal,
            toItem: effectView,
            attribute: .CenterX,
            multiplier: 1,
            constant: 0)
        let centerY = NSLayoutConstraint(item: infoLabel,
            attribute: .CenterY,
            relatedBy: .Equal,
            toItem: effectView,
            attribute: .CenterY,
            multiplier: 1,
            constant: 0)
        effectView.addConstraints([centerX, centerY])
    }

    private func setupNotesView() {
        notesView.setTranslatesAutoresizingMaskIntoConstraints(false)
        notesView.font = UIFont.systemFontOfSize(30)
        notesView.backgroundColor = UIColor.clearColor()
        notesView.textColor = UIColor.whiteColor()
        notesView.userInteractionEnabled = false
        notesView.alpha = 0
        effectView.addSubview(notesView)

        let horizontal = NSLayoutConstraint.constraintsWithVisualFormat("|[notesView]|", options: nil, metrics: nil, views: ["notesView": notesView])
        let vertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[notesView]|", options: nil, metrics: nil, views: ["notesView": notesView])
        effectView.addConstraints(horizontal)
        effectView.addConstraints(vertical)
    }

    private func setupNextSlideView() {
        nextSlideView.setTranslatesAutoresizingMaskIntoConstraints(false)
        nextSlideView.contentMode = UIViewContentMode.ScaleAspectFit
        effectView.addSubview(nextSlideView)

        // Constraints
        let ratio = NSLayoutConstraint(item: nextSlideView,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nextSlideView,
            attribute: .Height,
            multiplier: 16.0/9,
            constant: 0)
        let height = NSLayoutConstraint(item: nextSlideView,
            attribute: .Height,
            relatedBy: .LessThanOrEqual,
            toItem: effectView,
            attribute: .Height,
            multiplier: 0.5,
            constant: 0)
        let left = NSLayoutConstraint(item: nextSlideView,
            attribute: .Left,
            relatedBy: .GreaterThanOrEqual,
            toItem: effectView,
            attribute: .Left,
            multiplier: 1,
            constant: 10)
        let right = NSLayoutConstraint(item: nextSlideView,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: effectView,
            attribute: .Right,
            multiplier: 1,
            constant: -10)
        let bottom = NSLayoutConstraint(item: nextSlideView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: effectView,
            attribute: .Bottom,
            multiplier: 1,
            constant: -10)
        effectView.addConstraints([ratio, height, left, right, bottom])
    }

    // MARK: Gestures

    func longPress(sender: UILongPressGestureRecognizer) {
        switch sender.state {
            case .Began:
                showNotes(true)
            case .Changed:
                break
            default:
                // Don't do anything if the effect view is now being used to show a connectivity message
                if let session = multipeerClient.session where session.connectedPeers.count > 0 {
                    showNotes(false)
                }
        }
    }

    private func showNotes(show: Bool) {
        if let presentation = presentation {
            let currentSlideIndex = Int(currentSlide())
            notesView.text = presentation.slides[currentSlideIndex].notes
            notesView.alpha = 1
            nextSlideView.alpha = 1

            if currentSlideIndex < presentation.slides.count - 1 {
                nextSlideView.image = presentation.slides[currentSlideIndex + 1].image
            } else {
                nextSlideView.image = nil
            }
            let alpha = CGFloat(show)
            UIView.animateWithDuration(0.25, animations: {
                self.effectParentView.alpha = alpha
            }) { finished in
                self.notesView.alpha = alpha
                self.nextSlideView.alpha = alpha
            }
        }
    }

    // MARK: Collection View

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presentation?.slides.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! Cell
        let slide = presentation?.slides[indexPath.item]
        cell.imageView.image = slide?.image
        return cell
    }

    // MARK: UIScrollViewDelegate

    private func currentSlide() -> UInt {
        if let collectionView = collectionView {
            return UInt(round(collectionView.contentOffset.x / collectionView.frame.size.width))
        }
        return 0
    }

    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        multipeerClient.sendString("\(currentSlide())")
    }

    // MARK: Rotation

    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {

        // Update Layout
        let layout = collectionView?.collectionViewLayout as? CollectionViewLayout
        layout?.invalidateLayout()
        layout?.itemSize = CGSize(width: view.bounds.size.height, height: view.bounds.size.width)

        // Update Offset
        let targetOffset = CGFloat(currentSlide()) * (layout?.itemSize.width ?? 0)

        // We do this half-way through the animation
        let delay = (duration / 2) * NSTimeInterval(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.collectionView?.contentOffset.x = targetOffset
        }
    }
}
