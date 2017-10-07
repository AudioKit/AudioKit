//
//  ViewController - AudioUnits.swift
//  AudioUnitManager
//
//  Created by Ryan Francesconi on 10/6/17.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import Cocoa
import AVFoundation
import AudioKit

extension ViewController {
    
    internal func initManager() {
        internalManager = AKAudioUnitManagerDev(inserts: 6)
        internalManager?.delegate = self
        
        internalManager?.requestEffects(completionHandler: { audioUnits in
            self.updateEffectsUI(audioUnits: audioUnits)
        })
        
        internalManager?.requestInstruments(completionHandler: { audioUnits in
            self.updateInstrumentsUI(audioUnits: audioUnits)
        })
    }
    
    func showEffect( at auIndex: Int, state: Bool ) {
        if auIndex > internalManager!.effectsChain.count - 1 {
            AKLog("index is out of range")
            return
        }
        
        if state {
            // get audio unit
            if let au = internalManager?.effectsChain[auIndex] {
                showAudioUnit(au, identifier: auIndex)
                
            } else {
                AKLog("Nothing at this index")
            }
            
        } else {
            if let w = getWindowFromIndentifier(String(auIndex)) {
                w.close()
            }
        }
    }
    
    func handleEffectSelected(_ auname: String, identifier: Int) {
        guard internalManager != nil else { return }
        AKLog("handleEffectSelected() \(identifier) \(auname)")
        
        if auname == "-" {
            if let button = getEffectsButtonFromIdentifier(identifier) {
                button.state = .off
            }
            if let menu = getMenuFromIdentifier(identifier) {
                menu.title = "▼ Insert \(identifier + 1)"
            }
            if let win = getWindowFromIndentifier(String(identifier)) {
                win.close()
            }
            internalManager!.removeEffect(at: identifier)
            
            return
        }
        internalManager!.insertAudioUnit(name: auname, at: identifier)
        
        // select the item in the menu
        selectEffectInMenu(name: auname, identifier: identifier)
    }
    
    func selectEffectInMenu(name: String, identifier: Int) {
        guard let button = getMenuFromIdentifier(identifier) else { return }
        guard let menu = button.menu else { return }
        
        var parentMenu: NSMenuItem?
        
        for man in menu.items {
            guard let sub = man.submenu else { continue }
            
            man.state = .off
            for item in sub.items {
                item.state = (item.title == name) ? .on : .off
                
                if item.state == .on {
                    parentMenu = man
                }
            }
        }
        
        if let pm = parentMenu {
            pm.state = .on
            button.title = "👉 \(name)"
        }
        
    }
    
    //MARK:- Build the effects menus
    fileprivate func updateEffectsUI( audioUnits: [AVAudioUnitComponent] ) {
        guard internalManager != nil else { return }
        
        var manufacturers = [String]()
        
        for component in audioUnits {
            let man = component.manufacturerName
            if !manufacturers.contains(man) {
                manufacturers.append(man)
            }
        }
        
        // going to put internal AUs in here
        manufacturers.append( akInternals )
        manufacturers.sort()
        
        // fill all the menus with the same list
        for sv in effectsContainer.subviews {
            guard let b = sv as? MenuButton else { continue }
            
            if b.menu == nil {
                let theMenu = NSMenu(title: "Effects")
                theMenu.font = NSFont.systemFont(ofSize: 10)
                b.menu = theMenu
            }
            
            b.menu?.removeAllItems()
            b.title = "▼ Insert \(b.tag + 1)"
            
            let blankItem = ClosureMenuItem(title: "-", closure: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.handleEffectSelected("-", identifier: b.tag)
            })
            
            b.menu?.addItem(blankItem)
            
            // first make a menu of manufacturers
            for man in manufacturers {
                let manItem = NSMenuItem()
                manItem.title = man
                manItem.submenu = NSMenu(title: man)
                b.menu?.addItem(manItem)
            }
            
            // then add each AU into it's parent folder
            for component in audioUnits {
                let item = ClosureMenuItem(title: component.name, closure: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.handleEffectSelected(component.name, identifier: b.tag)
                })
                
                // manufacturer list
                for man in b.menu!.items {
                    if man.title == component.manufacturerName {
                        man.submenu?.addItem(item)
                    }
                }
            }
            
            let internalSubmenu = b.menu?.items.filter{ $0.title == akInternals }.first
            
            for name in internalManager!.internalAudioUnits {
                let item = ClosureMenuItem(title: name, closure: { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.handleEffectSelected(name, identifier: b.tag)
                })
                internalSubmenu?.submenu?.addItem(item)
            }
        }
    }
    
    internal func getMenuFromIdentifier(_ id: Int ) -> MenuButton? {
        guard effectsContainer != nil else { return nil }
        
        for sv in effectsContainer.subviews {
            guard let b = sv as? MenuButton else { continue }
            if b.tag == id {
                return b
            }
        }
        return nil
    }
    
    internal func getWindowFromIndentifier(_ id: String ) -> NSWindow? {
        
        guard let windows = self.view.window?.childWindows else { return nil }
        
        for w in windows {
            if w.identifier?.rawValue == id {
                return w
            }
        }
        
        return nil
    }
    
    internal func getEffectsButtonFromIdentifier(_ id: Int ) -> NSButton? {
        guard effectsContainer != nil else { return nil }
        
        for sv in effectsContainer.subviews {
            if sv.isKind(of: NSButton.self) && !sv.isKind(of: NSPopUpButton.self) {
                let b = sv as! NSButton
                if b.tag == id {
                    return b
                }
            }
        }
        return nil
    }
    
    public func showAudioUnit(_ audioUnit: AVAudioUnit, identifier: Int ) {
        
        audioUnit.auAudioUnit.requestViewController { [weak self] viewController in
            var ui = viewController
            guard let strongSelf = self else { return }
            guard let auName = audioUnit.auAudioUnit.audioUnitName else { return }
            
            DispatchQueue.main.async {
                if ui == nil || auName.startsWith(string: "AK") {
                    //AKLog("No ViewController for \(audioUnit.name )")
                    ui = NSViewController()
                    ui!.view = AudioUnitGenericView(au: audioUnit)
                }
                
                AKLog("Audio Unit incoming frame: \(ui!.view.frame)")
                
                guard let selfWindow = strongSelf.view.window else { return }
                
                let unitWindow = NSWindow(contentViewController: ui!)
                unitWindow.title = "\(auName)"
                unitWindow.delegate = self
                unitWindow.identifier = NSUserInterfaceItemIdentifier(String(identifier))
                
                if ui!.view.isKind(of: AudioUnitGenericView.self) {
                    if let gauv = ui?.view as? AudioUnitGenericView {
                        let gauvLoc = unitWindow.frame.origin
                        let f = NSMakeRect(gauvLoc.x, gauvLoc.y, 400, gauv.preferredHeight)
                        unitWindow.setFrame(f, display: true)
                    }
                }
                
                if let w = strongSelf.getWindowFromIndentifier(String(identifier)) {
                    unitWindow.setFrameOrigin( w.frame.origin )
                    w.close()
                }
                
                selfWindow.addChildWindow(unitWindow, ordered: NSWindow.OrderingMode.above)
                unitWindow.setFrameOrigin(NSPoint(x:selfWindow.frame.origin.x, y:selfWindow.frame.origin.y - unitWindow.frame.height))
                
                if let button = strongSelf.getEffectsButtonFromIdentifier( identifier ) {
                    button.state = .on
                }
                
            } //dispatch
        }
    }
    
    
}

extension ViewController:  AKAudioUnitManagerDelegate {
    func handleAudioUnitNotification(type: AKAudioUnitManager.Notification, object: Any?) {
        guard internalManager != nil else { return }
        
        if type == AKAudioUnitManager.Notification.changed {
            updateEffectsUI( audioUnits: internalManager!.availableEffects )
        }
    }
    
    func handleEffectAdded( at auIndex: Int ) {
        showEffect(at: auIndex, state: true)
        
        guard internalManager != nil else { return }
        guard mixer != nil else { return }
        
        // is FM playing?
        if fm != nil && fm!.isStarted {
            internalManager!.connectEffects(firstNode: fm, lastNode: mixer)
            return
        }
        
        guard player != nil else { return }
        
        let playing = player!.isStarted
        
        if playing {
            player!.stop()
        }
        
        internalManager!.connectEffects(firstNode: player, lastNode: mixer)
        
        if playing {
            player!.start()
        }
    }
}
