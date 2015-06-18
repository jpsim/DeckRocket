//
//  InterfaceController.swift
//  DeckRocket WatchKit Extension
//
//  Created by Esteban Torres on 16/6/15.
//
//

import WatchKit
import Foundation
import MultipeerConnectivity


class InterfaceController: WKInterfaceController {

    private var slidesCount: Int = 0 {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.infoGroup.setHidden(self.slidesCount != 0)
                self.slidesInfoGroup.setHidden(false)
                // Trigger state change block
                self.multipeerClient.onStateChange??(state: self.multipeerClient.state, peerID: MCPeerID())
            }
        }
    }
    private let multipeerClient = MultipeerClient()
    
    @IBOutlet weak var infoGroup: WKInterfaceGroup!
    @IBOutlet weak var slidesInfoGroup: WKInterfaceGroup!
    @IBOutlet weak var slider: WKInterfaceSlider!
    @IBOutlet weak var slidesCountLabel: WKInterfaceLabel!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        self.setupConnectivityObserver()
        // Trigger state change block
        self.multipeerClient.onStateChange??(state: self.multipeerClient.state, peerID: MCPeerID())
    }

    @IBAction func sliderValueChanged(value: Float) {
        // Since `WKInterfaceSlider` «maximum»'s property can't be set at runtime
        // we set it as 100 and manage the steps as «percentages».
        // Here we transform the «percentage» to the slider number.
        let currentSlide = Int(value) * self.slidesCount / 100
        multipeerClient.sendString("\(currentSlide)")
        self.slidesCountLabel.setText("Slide: \(currentSlide + 1)/\(self.slidesCount)")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // MARK: Connectivity Updates
    
    private func setupConnectivityObserver() {
        self.slidesCountLabel.setText("Waiting for slides 🚀")
        multipeerClient.onSlidesReceived = { slides in
            dispatch_async(dispatch_get_main_queue()) {
                self.slidesCount = Int(slides.count)
                self.slider.setNumberOfSteps(self.slidesCount)
                self.slider.setValue(1)
                self.slidesCountLabel.setText("Slide: 1/\(self.slidesCount)")
            }
        }
        
        multipeerClient.onStateChange = { state, peerID in
            let client = self.multipeerClient
            let borderColor: UIColor
            switch state {
            case .NotConnected:
                borderColor = UIColor.redColor()
                guard let browser = client.browser, session = client.session
                    where session.connectedPeers.count == 0 else { break }
                browser.invitePeer(peerID, toSession: session, withContext: nil, timeout: 30)
            case .Connecting:
                borderColor = UIColor.orangeColor()
            case .Connected:
                borderColor = UIColor.greenColor()
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.infoGroup.setBackgroundColor(borderColor)
            }
        }
    }
}
