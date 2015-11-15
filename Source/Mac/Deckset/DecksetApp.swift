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
        // swiftlint:disable force_cast
        return ((sbApp.documents as AnyObject).valueForKey("get") as! [AnyObject])
            .map(DecksetDocument.init)
        // swiftlint:enable force_cast
    }

    /// Windows.
    var windows: [DecksetWindow] {
        // swiftlint:disable force_cast
        return ((sbApp.windows as AnyObject).valueForKey("get") as! [AnyObject])
            .map(DecksetWindow.init)
        // swiftlint:enable force_cast
    }

    /// The name of the application.
    var name: String {
        // swiftlint:disable force_cast
        return sbApp.valueForKey("name") as! String
        // swiftlint:enable force_cast
    }

    /// Is this the active application?
    var frontmost: Bool {
        // swiftlint:disable force_cast
        return sbApp.valueForKey("frontmost") as! Bool
        // swiftlint:enable force_cast
    }

    /// The version number of the application.
    var version: String {
        // swiftlint:disable force_cast
        return sbApp.valueForKey("version") as! String
        // swiftlint:enable force_cast
    }

    /// Show the preview window?
    var preview: Bool {
        // swiftlint:disable force_cast
        return sbApp.valueForKey("preview") as! Bool
        // swiftlint:enable force_cast
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
    init?(beta: Bool = false) {
        let bundleID = "com.unsignedinteger.Deckset" + (beta ? "-private-beta" : "")
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
    func open(document: AnyObject) -> AnyObject {
        return sbApp.open(document)
    }

    /// Quit the application.
    func quit() {
        sbApp.quit()
    }
}
