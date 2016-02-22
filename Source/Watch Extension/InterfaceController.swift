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

class TableRowController: NSObject {
    @IBOutlet var image: WKInterfaceImage!
}

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet var table: WKInterfaceTable!
    private let session = WCSession.defaultSession()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        session.delegate = self
        session.activateSession()
    }

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        super.table(table, didSelectRowAtIndex: rowIndex)
        session.sendMessage(["row": rowIndex], replyHandler: { _ in }, errorHandler: nil)
    }

    func session(session: WCSession, didReceiveMessageData messageData: NSData) {
        let slides = Slide.slidesfromData(messageData)!
        table.setNumberOfRows(slides.count, withRowType: "\(TableRowController.self)")
        for (index, slide) in slides.enumerate() {
            let row = table.rowControllerAtIndex(index) as! TableRowController
            row.image.setImage(slide!.image)
        }
    }
}
