//
//  FileManagerUtils.swift
//  Synth Two
//
//  Created by Shane Dunne, revision history on Githbub.
//  Copyright © 2017 Shane Dunne. All rights reserved.
//

import Foundation

class FileManagerUtils {

    static let shared = FileManagerUtils()

    let fileMgr = FileManager.default

    func getDocsUrl(_ fileName: String) -> URL {
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        let docsURL = dirPaths.first!
        return docsURL.appendingPathComponent(fileName)
    }

    func getDocsPath() -> String {
        return fileMgr.urls(for: .documentDirectory, in: .userDomainMask).first!.path
    }

    func getDocsPath(_ fileName: String) -> String {
        return getDocsUrl(fileName).path
    }

    func createFolders(_ folderName: String) {
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        let docsURL = dirPaths.first!

        //let srcURL = Bundle.main.resourceURL!.appendingPathComponent(folderName)
        let dstURL = docsURL.appendingPathComponent(folderName)

        do {
            try fileMgr.createDirectory(at: dstURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Could not create destination directory")
        }
    }

    func copyFile(_ fileName: String) {
        let dirPaths = fileMgr.urls(for: .documentDirectory, in: .userDomainMask)
        let docsURL = dirPaths.first!
        let dstURL = docsURL.appendingPathComponent(fileName)
        let srcURL = Bundle.main.resourceURL!.appendingPathComponent(fileName)

        do {
            try fileMgr.copyItem(at: srcURL, to: dstURL)
        } catch {
            print("Could not copy \(fileName)")
        }
    }

    func copyFiles(pathFromBundle: String, pathDestDocs: String) {
        do {
            let filelist = try fileMgr.contentsOfDirectory(atPath: pathFromBundle)

            for filename in filelist {
                print("Copying from \(pathFromBundle)/\(filename) to \(pathDestDocs)/\(filename)")
                try? fileMgr.copyItem(atPath: "\(pathFromBundle)/\(filename)", toPath: "\(pathDestDocs)/\(filename)")
            }
        } catch {
            print("copyFiles error\n")
        }
    }

}
