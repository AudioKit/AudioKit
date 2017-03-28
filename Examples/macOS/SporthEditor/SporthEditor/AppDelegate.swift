//
//  AppDelegate.swift
//  SporthEditor
//
//  Created by Kanstantsin Linou on 7/14/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    lazy var controlsWindowController: NSWindowController? = {
        let storyboard = NSStoryboard(name: Constants.Name.storyboard, bundle: nil)
        let controlsWindowController = storyboard.instantiateController(
            withIdentifier: Constants.Identifier.controlsController) as! NSWindowController
        return controlsWindowController
    }()

    @IBAction func openControlsWindow(_ sender: AnyObject?) {
        controlsWindowController?.showWindow(self)
    }

    @IBAction func openDocument(_ sender: AnyObject?) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = [FileUtilities.fileExtension]

        if panel.runModal() == NSModalResponseCancel {
            return
        }

        if let path = panel.url?.path {
            guard let vc = NSApplication.shared().windows.first!.contentViewController as? ViewController else {
                return
            }
            vc.brain.stop()
            vc.path = path
            let code = try? NSString(contentsOf: URL(fileURLWithPath: path), encoding: String.Encoding.utf8.rawValue)
            if let code = code {
                vc.display = String(code)
            }
        }
    }

    @IBAction func saveDocument(_ sender: AnyObject?) {
        guard let vc = NSApplication.shared().windows.first!.contentViewController as? ViewController else {
            return
        }

        guard !vc.display.isEmpty else {
            presentAlert(Error.code)
            return
        }

        if let path = vc.path {
            do {
                try vc.display.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                NSLog(Constants.Error.Saving)
            }
        } else {
            saveDocumentAs(sender)
        }
    }

    @IBAction func saveDocumentAs(_ sender: AnyObject?) {
        guard let vc = NSApplication.shared().windows.first!.contentViewController as? ViewController else {
            return
        }

        guard !vc.display.isEmpty else {
            presentAlert(Error.code)
            return
        }

        let savePanel = NSSavePanel()
        savePanel.isExtensionHidden = true
        savePanel.message = Constants.Message.save
        savePanel.allowedFileTypes = [FileUtilities.fileExtension]

        if savePanel.runModal() == NSModalResponseCancel {
            return
        }

        if let path = savePanel.url?.path {
            do {
                try vc.display.write(to: URL(fileURLWithPath: path), atomically: true, encoding: String.Encoding.utf8)
                vc.path = String(path)
            } catch {
                NSLog(Constants.Error.Saving)
            }
        }
    }

    func presentAlert(_ error: Error) {
        let alert = NSAlert()
        switch error {
        case .code:
            alert.messageText = Constants.Code.title
            alert.informativeText = Constants.Code.message
        default:
            alert.messageText = Constants.Name.title
            alert.informativeText = Constants.Name.message
        }
        alert.addButton(withTitle: Constants.Message.ok)
        alert.runModal()
    }
}
