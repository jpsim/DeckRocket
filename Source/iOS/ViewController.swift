//
//  ViewController.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Cartography

final class ViewController: UICollectionViewController, UIScrollViewDelegate {

    // MARK: Properties

    var slides: [Slide]? {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.infoLabel.hidden = self.slides != nil
                self.collectionView?.contentOffset.x = 0
                self.collectionView?.reloadData()
                // Trigger state change block
                self.multipeerClient.onStateChange??(state: self.multipeerClient.state, peerID: MCPeerID())
            }
        }
    }
    private let multipeerClient = MultipeerClient()
    private let infoLabel = UILabel()

    // MARK: View Lifecycle

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        super.init(collectionViewLayout: layout)
    }

    convenience required init(coder aDecoder: NSCoder) {
        self.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConnectivityObserver()
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        if let slidesData = NSData(contentsOfFile: documentsPath.stringByAppendingPathComponent("slides")) {
            slides = flatMap(Slide.slidesfromData(slidesData)) { compact($0) }
        }
    }

    // MARK: Connectivity Updates

    private func setupConnectivityObserver() {
        multipeerClient.onSlidesReceived = { slides in
            if let rootVC = UIApplication.sharedApplication().delegate?.window??.rootViewController as? ViewController {
                rootVC.slides = slides
            }
        }
        
        multipeerClient.onStateChange = { state, peerID in
            let client = self.multipeerClient
            let borderColor: CGColorRef
            switch state {
            case .NotConnected:
                borderColor = UIColor.redColor().CGColor
                if client.session?.connectedPeers.count == 0 {
                    client.browser?.invitePeer(peerID, toSession: client.session, withContext: nil, timeout: 30)
                }
            case .Connecting:
                borderColor = UIColor.orangeColor().CGColor
            case .Connected:
                borderColor = UIColor.greenColor().CGColor
            }
            dispatch_async(dispatch_get_main_queue()) {
                collectionView?.layer.borderColor = borderColor
            }
        }
    }

    // MARK: UI

    private func setupUI() {
        setupCollectionView()
        setupInfoLabel()
    }

    private func setupCollectionView() {
        collectionView?.registerClass(Cell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.pagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.layer.borderColor = UIColor.redColor().CGColor
        collectionView?.layer.borderWidth = 2
        setCollectionViewItemSize(view.bounds.size)
    }

    private func setupInfoLabel() {
        infoLabel.userInteractionEnabled = false
        infoLabel.numberOfLines = 0
        infoLabel.text = "Thanks for installing DeckRocket!\n\n" +
            "To get started, follow these simple steps:\n\n" +
            "1. Open a presentation in Deckset on your Mac.\n" +
            "2. Launch DeckRocket on your Mac.\n" +
            "3. Click the DeckRocket menu bar icon and select \"Send Slides\".\n\n" +
            "From there, swipe on your phone to control your Deckset slides, " +
            "tap the screen to toggle between current slide and notes view, and finally: " +
        "keep an eye on the color of the border! Red means the connection was lost. Green means everything should work!"
        infoLabel.textColor = UIColor.whiteColor()
        view.addSubview(infoLabel)

        layout(infoLabel, view) {
            $0.left   == $1.left  + 20
            $0.right  == $1.right - 20
            $0.top    == $1.top
            $0.bottom == $1.bottom
        }
    }

    // MARK: Collection View

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides?.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! Cell
        cell.imageView.image = slides?[indexPath.item].image
        cell.notesView.text = slides?[indexPath.item].notes
        cell.nextSlideView.image = indexPath.item + 1 < slides?.count ? slides?[indexPath.item + 1].image : nil
        return cell
    }

    // MARK: UIScrollViewDelegate

    private func currentSlide() -> UInt {
        return map(collectionView) { cv in
            let cvLayout = cv.collectionViewLayout as! UICollectionViewFlowLayout
            return UInt(round(cv.contentOffset.x / cvLayout.itemSize.width))
            } ?? 0
    }

    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        multipeerClient.sendString("\(currentSlide())")
    }

    // MARK: Rotation

    private func setCollectionViewItemSize(size: CGSize) {
        let cvLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        cvLayout?.itemSize = size
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        let current = currentSlide()
        UIView.animateWithDuration(coordinator.transitionDuration()) {
            self.collectionView?.contentOffset.x = CGFloat(current) * size.width
        }
        setCollectionViewItemSize(size)
    }
}
