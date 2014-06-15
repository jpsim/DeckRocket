#!/usr/bin/osascript

on run argv
    set idx to item 1 of argv
    if application "Deckset private beta" is running
        tell application "Deckset private beta"
            tell first item of documents
                set slideIndex to idx
            end tell
        end tell
    end if
end run
