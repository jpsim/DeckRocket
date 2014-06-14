#!/usr/bin/osascript

on run argv
	set idx to item 1 of argv
    if application "Deckset private beta" is running
        tell application "Deckset private beta"
            repeat with doc in documents
                tell doc
                	set slideIndex to idx
                end tell
            end repeat
        end tell
    end if
end run
