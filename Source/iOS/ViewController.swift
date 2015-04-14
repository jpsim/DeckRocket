//
//  ViewController.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import UIKit
import MultipeerConnectivity

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
        super.init(collectionViewLayout: CollectionViewLayout())
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
    }

    private func setupInfoLabel() {
        infoLabel.userInteractionEnabled = false
        infoLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
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

        // Constraints
        let horizontal = NSLayoutConstraint.constraintsWithVisualFormat("|-20-[infoLabel]-20-|", options: nil, metrics: nil, views: ["infoLabel": infoLabel])
        let vertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|[infoLabel]|", options: nil, metrics: nil, views: ["infoLabel": infoLabel])
        view.addConstraints(horizontal)
        view.addConstraints(vertical)
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
