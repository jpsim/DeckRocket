//
//  ViewController.swift
//  DeckRocket
//
//  Created by JP Simard on 2/22/16.
//  Copyright (c) 2016 JP Simard. All rights reserved.
//

import Foundation
import RealmSwift
import WatchConnectivity
import WatchKit

final class TableRowController: NSObject {
    @IBOutlet var image: WKInterfaceImage!
}

final class RealmSlide: Object {
    dynamic var imageData = NSData()

    convenience init(slide: Slide) {
        self.init()
        imageData = UIImageJPEGRepresentation(slide.image, 0.8)!
    }
}

final class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet var table: WKInterfaceTable!
    private let session = WCSession.defaultSession()
    private var notificationToken: NotificationToken? = nil
    private var realm: Realm? = nil
    private var slides: Results<RealmSlide>? = nil

    override func willActivate() {
        super.willActivate()
        session.delegate = self
        session.activateSession()

        do {
            realm = try Realm()
            slides = realm?.objects(RealmSlide)
            notificationToken = slides?.addNotificationBlock { [unowned self] _, _ in
                self.updateSlides()
            }
        } catch {
            print("error: \(error)")
        }
    }

    override func didDeactivate() {
        notificationToken?.stop()
        super.didDeactivate()
    }

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        super.table(table, didSelectRowAtIndex: rowIndex)
        session.sendMessage(["row": rowIndex], replyHandler: { _ in }, errorHandler: nil)
    }

    func session(session: WCSession, didReceiveMessageData messageData: NSData) {
        let slides = Slide.slidesfromData(messageData)!
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
                realm.add(slides.flatMap({ $0 }).flatMap({ RealmSlide(slide: $0) }))
            }
        } catch {
            print("error: \(error)")
        }
    }

    private func updateSlides() {
        guard let slides = slides else { return }
        table.setNumberOfRows(slides.count, withRowType: "\(TableRowController.self)")
        for (index, slide) in slides.enumerate() {
            // swiftlint:disable:next force_cast
            let row = table.rowControllerAtIndex(index) as! TableRowController
            row.image.setImage(UIImage(data: slide.imageData))
        }
    }
}
