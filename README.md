# DeckRocket

![](design/math.jpg)

## DeckRocket turns your iPhone into a remote for [Deckset](http://decksetapp.com) presentations

![](demo.gif)

## Requirements

DeckRocket is built in Swift and relies on Multipeer Connectivity on both OSX and iOS. Therefore Xcode 6.1, OS X 10.10 and iOS 8 are all required to build, install and use DeckRocket.

## Usage

![](dragdrop.gif)

1. Make sure you have the requirements listed above and that Deckset is running (with your presentation as the current document).
2. Open and run both `OSX/DeckRocket.xcodeproj` and `iOS/DeckRocket.xcodeproj`. You should see a :rocket: icon in your menu bar.
3. Export your Deckset presentation as a PDF.
4. Drag your PDF onto the :rocket: icon in your Mac's menu bar. The file should start transferring to your iOS device instantly.
5. (Optional) Repeat step 4 with your presentation's markdown file for access to presenter notes in the remote app. To show your notes and preview the next slide, simply press and hold.

A connection should be established between the OSX and iOS apps within a few seconds. You'll then be able to swipe through your slides and see Deckset navigate to them fairly instantly.

The magic of Multipeer Connectivity should allow this to work even if devices have no Internet connectivity and aren't even on the same WiFi network. But they must both have either Bluetooth or WiFi turned on.

## License

This project is MIT licensed and was developed independently from Deckset and Unsigned Integer (but those guys are great!).
