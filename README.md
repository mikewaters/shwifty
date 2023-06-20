# shwifty
Dump some information about the applications residing in your Launchpad

## What?
Launchpad stores all of its applications and metadata in a sqlite3 database somewhere in /tmp.

I was interested in understanding "where all my shit is", and figured it would be easy to just list all of the Launchpad app paths.

It wasn't.

## How? (does this work)
So not only is the config in a database (and the launchpad "feature logic" uses triggers and all that fun), the metadata is in a BLOB column.
Not just *any* blob, but a serialized-from-frickin-memory object of the type `NSURLBookmark`. Digging into how the mac internals work is shit-producingly scary and pretty damn impressive all at once. This is both strongly-typed AND drunk behind the steering wheel.

Anyway, this code reads the blobs, shoves them into the right type (-ish) of object, and dumps it to stdout.

## How?? (do I use this)
Because we've all operated production systems, first locally copy the Launchpad db to the course code directory.

    cp $(getconf DARWIN_USER_DIR)/com.apple.dock.launchpad/db/db ./

Then build and run this. I used vscode, as I've only ever written a few lines of Swift (which is pretty cool) and Xcode can suck a duck for all the times I've had to update its command line tools to do something silly like retrieve a directory listing.

## How??? (can I avoid doing this)
You cant, but you *can* get a bunch of info from just looking at the launchpad database.

    # dump a single sample launchpad record's bookmark to a local file, by:
    # translating the sqlite BLOB binary column to hex in-database, to stdout, 
    # and bringing it back to a binary file that you can inspect in your hex editor:
    sqlite3  $(getconf DARWIN_USER_DIR)/com.apple.dock.launchpad/db/db 'select hex(bookmark) from apps limit 1' | xxd -r -p > some-launchpad-app-bookmark.bin

## Also
This guy - whoever he/she is, is brilliant and I could not have done it without their almost ten years of blogs:
https://eclecticlight.co/2020/07/28/universal-binaries-inside-fat-headers/

## Example output
```
title|path
Jump Desktop Connect|/Applications/Jump Desktop Connect.app
Siri|/System/Applications/Siri.app
Tamper Chrome (application)|/Users/yourmother/Applications/Chrome Apps.localized/Tamper Chrome (application).app
Sid Meier's Civilization VI|/Users/mike/Applications/Sid Meier's Civilization VI.app
Music|/System/Applications/Music.app
Visual Studio Code|/Applications/Visual Studio Code.app
```