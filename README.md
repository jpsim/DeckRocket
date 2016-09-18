# DeckRocket

![](design/math.jpg)

## DeckRocket turns your iPhone into a remote for [Deckset](http://decksetapp.com) presentations

![](demo.gif)

## Requirements

DeckRocket is built in Swift and relies on Multipeer Connectivity on both OS X
and iOS. Xcode 7.3.1, OS X 10.10 (and up) and iOS 8 (and up) are all required to
build, install and use DeckRocket.

## Usage

1. Make sure you meet the requirements listed above.
2. Run `git submodule update --init`
2. Build and run both the "Mac" and "iOS" schemes in the `DeckRocket.xcodeproj`
   Xcode project. You should see a :rocket: icon in your menu bar.
3. Open a presentation in Deckset on your Mac.
4. Click the DeckRocket menu bar icon and select "Send Slides".

From there, swipe on your phone to control your Deckset slides, tap the screen
to toggle between current slide and notes view, and finally: keep an eye on the
color of the border!

Red means the connection was lost. Green means everything should work!

A connection should be established between the Mac and iOS apps within a few
seconds. You'll then be able to swipe through your slides and see Deckset
navigate to them fairly instantly.

The magic of Multipeer Connectivity should allow this to work even if devices
have no Internet connectivity and aren't even on the same WiFi network. But they
must both have either Bluetooth or WiFi turned on.

## License

This project is MIT licensed and was developed independently from Deckset and
Unsigned Integer (but those guys are great!).
