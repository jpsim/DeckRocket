//
//  ViewController.swift
//  DeckRocket
//
//  Created by JP Simard on 2/22/16.
//  Copyright (c) 2016 JP Simard. All rights reserved.
//

import Foundation
import WatchConnectivity
import WatchKit

final class TableRowController: NSObject {
    @IBOutlet var image: WKInterfaceImage!
}

final class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet var table: WKInterfaceTable!
    private let session = WCSession.default

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        session.delegate = self
        session.activate()
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        super.table(table, didSelectRowAt: rowIndex)
        session.sendMessage(["row": rowIndex], replyHandler: { _ in }, errorHandler: nil)
    }

    @available(watchOSApplicationExtension 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // nothing to do
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        let slides = Slide.slidesfromData(data: messageData as NSData)!
        table.setNumberOfRows(slides.count, withRowType: "\(TableRowController.self)")
        for (index, slide) in slides.enumerated() {
            // swiftlint:disable:next force_cast
            let row = table.rowController(at: index) as! TableRowController
            row.image.setImage(slide!.image)
        }
    }
}
