// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SQLite

enum URLBookmarkKeys: String {
    case path = "_NSURLPathKey"
    case all = "NSURLBookmarkAllPropertiesKey"
}

let args = CommandLine.arguments
print("args: \(args)")
// could be replaced with path to actual launchpad db
let copyOfLaunchpadDatabaseName: String = "db" 

do {
    let db: Connection = try Connection(copyOfLaunchpadDatabaseName)
    let apps: Table = Table("apps")
    let title: Expression<String> = Expression<String>("title")
    let bookmark: Expression<Data> = Expression<Data>("bookmark")
    /**
    Dump all the possible keys
    **/
    if let whatev: Row = try db.pluck(apps.select(bookmark)) {
        let keys: NSDictionary = getKeysFromBinary(bookmark: whatev[bookmark])
        print("\(keys.allKeys)")
    }
    /**
    Dump the app path key for each app in the Launchpad database
    **/
    print("title|path")
    for app: Row in try db.prepare(apps.select(title, bookmark)) {
        let path: String = getKeyFromBinary(bookmark: app[bookmark], keyName: URLBookmarkKeys.path.rawValue)
        print("\(app[title])|\(path)")

    }
} 
catch {
    print("Error: \(error)")
}

func getKeyFromBinary(bookmark: Data, keyName: String) -> String {
    let bookmarkObj: NSDictionary = NSURL.resourceValues(forKeys: [URLResourceKey(rawValue: keyName)], fromBookmarkData: bookmark)! as NSDictionary
    //let bookmarkPath: NSDictionary = bookmarkObj ?? [:]
    return bookmarkObj[keyName] as! String
}
func getKeysFromBinary(bookmark: Data) -> NSDictionary {
    let bookmarkPath: NSDictionary = funkydonkey(keyName: URLBookmarkKeys.all.rawValue, blobOfShit: bookmark) ?? [:]
    return bookmarkPath[URLBookmarkKeys.all.rawValue] as! NSDictionary
}

func funkydonkey(keyName: String, blobOfShit: Data) -> NSDictionary? {
    let bookmarkObj: NSDictionary = NSURL.resourceValues(forKeys: [URLResourceKey(rawValue: keyName)], fromBookmarkData: blobOfShit)! as NSDictionary
    return bookmarkObj
}

func readLocalBinaryFile(file: String = "app.bin") {

    let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(file)

    //let fileURL = dir.appendingPathComponent(file)
    //let fileURL = URL(string: dir, relativeTo: nil) //"file:///" + dir + "/" + file)
    if (FileManager.default.fileExists(atPath: fileURL.path)) {
        print(fileURL.path)

        let bookmarkPath = funky(keyName: "_NSURLPathKey", blobOfShitLoc: fileURL) ?? [:]
        print(bookmarkPath["_NSURLPathKey"] as! String)

    }
    else {
        print("File does not exist")
    }
}
func getPathKey(bookmark: URL) -> String {
    let bookmarkPath: NSDictionary = funky(keyName: "_NSURLPathKey", blobOfShitLoc: bookmark) ?? [:]
    return bookmarkPath["_NSURLPathKey"] as! String
}
func funky(keyName: String, blobOfShitLoc: URL) -> NSDictionary? {
    do {
        let bookmarkData: Data = try Data(contentsOf: blobOfShitLoc)
        //let bookmarkObj: [URLResourceKey : Any]? = NSURL.resourceValues(forKeys: [URLResourceKey(rawValue: keyName)], fromBookmarkData: bookmarkData)
        let bookmarkObj = NSURL.resourceValues(forKeys: [URLResourceKey(rawValue: keyName)], fromBookmarkData: bookmarkData)! as NSDictionary
        return bookmarkObj
    }
    catch {
        print("Error parsing bookmark data: \(error) for " + blobOfShitLoc.path)
    }
    return nil
}

func getBookmarkData (bookmarkURL: URL) -> [URLResourceKey : Any]? {
    do {
        let bookmarkData: Data = try Data(contentsOf: bookmarkURL)
        let bookmarkObj: [URLResourceKey : Any]? = NSURL.resourceValues(forKeys: [URLResourceKey(rawValue: "NSURLBookmarkAllPropertiesKey")], fromBookmarkData: bookmarkData)
        return bookmarkObj
    }
    catch {
        print("Error parsing bookmark data: \(error) for " + bookmarkURL.path)
    }
    return nil
}
func getBookmarkPath (bookmarkURL: URL) -> [URLResourceKey : Any]? {
    do {
        let bookmarkData: Data = try Data(contentsOf: bookmarkURL)
        let bookmarkObj: [URLResourceKey : Any]? = NSURL.resourceValues(forKeys: [URLResourceKey(rawValue: "NSURLBookmarkOriginalRelativePathKey")], fromBookmarkData: bookmarkData)
        return bookmarkObj
    }
    catch {
        print("Error parsing bookmark data: \(error) for " + bookmarkURL.path)
    }
    return nil
}
