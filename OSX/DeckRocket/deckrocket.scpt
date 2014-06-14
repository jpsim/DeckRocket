#!/usr/bin/osascript

on run argv
	set idx to item 1 of argv
    if application "Deckset" is running
        tell application "Deckset"
            tell first item of documents
                set slideIndex to idx
            end tell
        end tell
    end if
end run
