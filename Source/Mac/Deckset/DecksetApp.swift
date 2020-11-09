//
//  DecksetApp.swift
//  DeckRocket
//
//  Created by JP Simard on 4/8/15.
//  Copyright (c) 2015 JP Simard. All rights reserved.
//

/// The application's top-level scripting object.
struct DecksetApp {

    // MARK: Properties

    private let sbApp: AnyObject

    /// Documents.
    var documents: [DecksetDocument] {
        return sbApp.documents().get()?.map { DecksetDocument(sbDocument: $0 as AnyObject) } ?? []
    }

    /// Windows.
    var windows: [DecksetWindow] {
        return sbApp.windows().get()?.map { DecksetWindow(sbWindow: $0 as! NSObject) } ?? []
    }

    /// The name of the application.
    var name: String {
        return sbApp.value(forKey: "name") as! String
    }

    /// Is this the active application?
    var frontmost: Bool {
        return sbApp.value(forKey: "frontmost") as! Bool
    }

    /// The version number of the application.
    var version: String {
        return sbApp.value(forKey: "version") as! String
    }

    /// Show the preview window?
    var preview: Bool {
        return sbApp.value(forKey: "preview") as! Bool
    }

    /// Show or hide the preview window.
    func setPreview(value: Bool) {
        return sbApp.setValue(value, forKey: "preview")
    }

    // MARK: Initializers

    /**
    Create a `DecksetApp` scripting object.

    - parameter beta: Whether or not to target the Deckset beta.
    */
    init?(beta: Bool = false, paddle: Bool = true) {
        let bundleID = "com.unsignedinteger.Deckset" +
            (beta ? "-private-beta" : "") +
            (paddle ? "-Paddle" : "")
        self.init(bundleID: bundleID)
    }

    /**
    Create a `DecksetApp` scripting object.

    - parameter bundleID: Bundle identifier of the deckset app to script.
    */
    private init?(bundleID: String) {
        guard let app = SBApplication(bundleIdentifier: bundleID) else {
            return nil
        }
        sbApp = app
    }

    // MARK: Functions

    /// Open a document.
    func open(document: AnyObject) -> Any! {
        return sbApp.open(document)
    }

    /// Quit the application.
    func quit() {
        sbApp.quit()
    }
}
