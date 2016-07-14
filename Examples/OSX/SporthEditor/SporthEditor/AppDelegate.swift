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
    
    
    @IBAction func openControlsWindow(sender: AnyObject?) {
        let storyboard = NSStoryboard(name: Constants.Name.storyboard, bundle: nil)
        let controlsWindowController = storyboard.instantiateControllerWithIdentifier(Constants.Identifier.controlsController) as! NSWindowController
        
        if let controlsWindow = controlsWindowController.window {
            let application = NSApplication.sharedApplication()
            application.runModalForWindow(controlsWindow)
        }
    }
    
    @IBAction func openDocument(sender: AnyObject?) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = [FileUtilities.fileExtension]
        
        if panel.runModal() == NSModalResponseCancel { return }
        
        if let path = panel.URL?.path {
            let vc = NSApplication.sharedApplication().windows.first!.contentViewController as! ViewController
            vc.brain.stop()
            vc.path = path
            let code = try? NSString(contentsOfURL: NSURL(fileURLWithPath: path), encoding: NSUTF8StringEncoding)
            if let code = code {
                vc.display = String(code)
            }
        }
    }
    
    @IBAction func saveDocument(sender: AnyObject?) {
        let vc = NSApplication.sharedApplication().windows.first!.contentViewController as! ViewController
        
        guard !vc.display.isEmpty else {
            presentAlert(Error.Code)
            return
        }
        
        if let path = vc.path {
            do {
                try vc.display.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
            } catch {
                NSLog(Constants.Error.Saving)
            }
        } else {
            saveDocumentAs(sender)
        }
    }
    
    @IBAction func saveDocumentAs(sender: AnyObject?) {
        let vc = NSApplication.sharedApplication().windows.first!.contentViewController as! ViewController
        
        guard !vc.display.isEmpty else {
            presentAlert(Error.Code)
            return
        }
        
        let savePanel = NSSavePanel()
        savePanel.extensionHidden = true
        savePanel.message = Constants.Message.save
        savePanel.allowedFileTypes = [FileUtilities.fileExtension]
        
        if savePanel.runModal() == NSModalResponseCancel { return }
        
        if let path = savePanel.URL?.path {
            do {
                try vc.display.writeToURL(NSURL(fileURLWithPath: path), atomically: true, encoding: NSUTF8StringEncoding)
                vc.path = String(path)
            } catch {
                NSLog(Constants.Error.Saving)
            }
        }
    }
    
    func presentAlert(error: Error) {
        let alert = NSAlert()
        switch error {
        case .Code:
            alert.messageText = Constants.Code.title
            alert.informativeText = Constants.Code.message
        default:
            alert.messageText = Constants.Name.title
            alert.informativeText = Constants.Name.message
        }
        alert.addButtonWithTitle(Constants.Message.ok)
        alert.runModal()
    }
}
