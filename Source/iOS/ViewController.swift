//
//  ViewController.swift
//  DeckRocket
//
//  Created by JP Simard on 6/13/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Cartography
import MultipeerConnectivity
import UIKit
import WatchConnectivity

final class ViewController: UICollectionViewController, WCSessionDelegate {

    // MARK: Properties

    var slides: [Slide]? {
        didSet {
            DispatchQueue.main.async {
                self.infoLabel.isHidden = self.slides != nil
                self.collectionView?.contentOffset.x = 0
                self.collectionView?.reloadData()
                // Trigger state change block
                self.multipeerClient.onStateChange??(self.multipeerClient.state,
                                                     MCPeerID(displayName: "placeholder"))
            }
            sendSlidesToWatch(session: watchConnectivitySession)
        }
    }
    private let multipeerClient = MultipeerClient()
    private let infoLabel = UILabel()
    private let watchConnectivitySession = WCSession.default

    // MARK: View Lifecycle

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        super.init(collectionViewLayout: layout)
        watchConnectivitySession.delegate = self
    }

    convenience required init(coder aDecoder: NSCoder) {
        self.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConnectivityObserver()
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                .userDomainMask, true)[0] as NSString
        if let slidesData = NSData(
            contentsOfFile: documentsPath.appendingPathComponent("slides")),
            let optionalSlides = Slide.slidesfromData(data: slidesData) {
            slides = optionalSlides.compactMap { $0 }
        }
        watchConnectivitySession.delegate = self
        watchConnectivitySession.activate()
        if watchConnectivitySession.isReachable {
            sendSlidesToWatch(session: watchConnectivitySession)
        }
    }

    // MARK: Connectivity Updates

    private func setupConnectivityObserver() {
        multipeerClient.onStateChange = { state, peerID in
            let client = self.multipeerClient
            let borderColor: UIColor
            switch state {
            case .notConnected:
                borderColor = .red
                if let session = client.session, session.connectedPeers.count == 0 {
                    client.browser?.invitePeer(peerID, to: session, withContext: nil,
                        timeout: 30)
                }
            case .connecting:
                borderColor = .orange
            case .connected:
                borderColor = .green
            @unknown default:
                borderColor = .red
            }
            DispatchQueue.main.async {
                self.collectionView?.layer.borderColor = borderColor.cgColor
            }
        }
    }

    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // already handled by 'onStateChange'
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        // already handled by 'onStateChange'
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // already handled by 'onStateChange'
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        sendSlidesToWatch(session: session)
    }

    private func sendSlidesToWatch(session: WCSession) {
        guard session.isReachable, let slides = slides else { return }

        let scaledSlides = slides.compactMap({ $0.dictionaryRepresentation })
        let data = NSKeyedArchiver.archivedData(withRootObject: scaledSlides)
        session.sendMessageData(data, replyHandler: nil, errorHandler: nil)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        replyHandler(message)
        DispatchQueue.main.async { [unowned self] in
            if let row = message["row"] as? CGFloat,
                let collectionView = self.collectionView,
                let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    collectionView.contentOffset.x = layout.itemSize.width * row
                self.multipeerClient.sendString(string: "\(row)" as NSString)
            }
        }
    }

    // MARK: UI

    private func setupUI() {
        setupCollectionView()
        setupInfoLabel()
    }

    private func setupCollectionView() {
        collectionView?.register(Cell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.layer.borderColor = UIColor.red.cgColor
        collectionView?.layer.borderWidth = 2
        setCollectionViewItemSize(size: view.bounds.size)
    }

    private func setupInfoLabel() {
        infoLabel.isUserInteractionEnabled = false
        infoLabel.numberOfLines = 0
        infoLabel.text = "Thanks for installing DeckRocket!\n\n" +
            "To get started, follow these simple steps:\n\n" +
            "1. Open a presentation in Deckset on your Mac.\n" +
            "2. Launch DeckRocket on your Mac.\n" +
            "3. Click the DeckRocket menu bar icon and select \"Send Slides\".\n\n" +
            "From there, swipe on your phone to control your Deckset slides, " +
            "tap the screen to toggle between current slide and notes view, and finally: " +
            "keep an eye on the color of the border! Red means the connection was lost. " +
            "Green means everything should work!"
        infoLabel.textColor = .white
        view.addSubview(infoLabel)

        constrain(infoLabel, view) {
            $0.left   == $1.left  + 20
            $0.right  == $1.right - 20
            $0.top    == $1.top
            $0.bottom == $1.bottom
        }
    }

    // MARK: Collection View

    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return slides?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                      for: indexPath) as! Cell // swiftlint:disable:this force_cast
        cell.imageView.image = slides?[indexPath.item].image
        cell.notesView.text = slides?[indexPath.item].notes
        cell.notesView.downsizeFontIfNeeded()

        if indexPath.item + 1 < (slides?.count ?? 0) {
            cell.nextSlideView.image = slides?[indexPath.item + 1].image
        } else {
            cell.nextSlideView.image = nil
        }
        return cell
    }

    // MARK: UIScrollViewDelegate

    private func currentSlide() -> UInt {
        guard let collectionView = collectionView,
            let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                return 0
        }
        return UInt(round(collectionView.contentOffset.x / layout.itemSize.width))
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        multipeerClient.sendString(string: "\(currentSlide())" as NSString)
    }

    // MARK: Rotation

    private func setCollectionViewItemSize(size: CGSize) {
        (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = size
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let current = currentSlide()
        UIView.animate(withDuration: coordinator.transitionDuration) {
            self.collectionView?.contentOffset.x = CGFloat(current) * size.width
        }
        setCollectionViewItemSize(size: size)
    }
}

private extension UITextView {
    func downsizeFontIfNeeded() {
        if (text.isEmpty || bounds.size.equalTo(.zero)) {
            return
        }

        while (sizeThatFits(CGSize(width: frame.size.width, height: .infinity)).height > frame.size.height) {
            font = font!.withSize(font!.pointSize - 1)
        }
    }

}
