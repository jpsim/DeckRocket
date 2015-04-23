/*
 * Deckset.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class DecksetApplication, DecksetSlide, DecksetDocument, DecksetWindow;



/*
 * Deckset Suite
 */

// The application's top-level scripting object.
@interface DecksetApplication : SBApplication

- (SBElementArray *) documents;
- (SBElementArray *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.
@property BOOL preview;  // Show the preview window?

- (id) open:(id)x;  // Open a document.
- (void) quit;  // Quit the application.

@end

// A slide.
@interface DecksetSlide : SBObject

@property (copy) NSString *notes;  // The notes of the text.
@property (copy) NSData *pdfData;  // The slide as PDF.

- (void) close;  // Close a document.

@end

// A document.
@interface DecksetDocument : SBObject

- (SBElementArray *) slides;

@property (copy, readonly) NSString *name;  // Its name.
@property (readonly) BOOL modified;  // Has it been modified since the last save?
@property (copy, readonly) NSURL *file;  // Its location on disk, if it has one.
@property NSInteger position;  // Position in the source file
@property NSInteger slideIndex;  // Index of the selected slide

- (void) close;  // Close a document.

@end

// A window.
@interface DecksetWindow : SBObject

@property (copy, readonly) NSString *name;  // The title of the window.
- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Does the window have a close button?
@property (readonly) BOOL miniaturizable;  // Does the window have a minimize button?
@property BOOL miniaturized;  // Is the window minimized right now?
@property (readonly) BOOL resizable;  // Can the window be resized?
@property BOOL visible;  // Is the window visible right now?
@property (readonly) BOOL zoomable;  // Does the window have a zoom button?
@property BOOL zoomed;  // Is the window zoomed right now?
@property (copy, readonly) DecksetDocument *document;  // The document whose contents are displayed in the window.

- (void) close;  // Close a document.

@end

