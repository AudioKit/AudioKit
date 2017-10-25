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
        internalManager = AKAudioUnitManager(inserts: 6)
        internalManager?.delegate = self

        internalManager?.requestEffects(completionHandler: { audioUnits in
            self.updateEffectsUI(audioUnits: audioUnits)
        })

        internalManager?.requestInstruments(completionHandler: { audioUnits in
            self.updateInstrumentsUI(audioUnits: audioUnits)
        })
    }

    internal func initUI() {
//        let colors = [NSColor(calibratedRed: 0.888, green: 0.888, blue: 0.888, alpha: 1),
//                      NSColor(calibratedRed: 0.748, green: 0.748, blue: 0.748, alpha: 1),
//                      NSColor(calibratedRed: 0.612, green: 0.612, blue: 0.612, alpha: 1),
//                      NSColor(calibratedRed: 0.558, green: 0.558, blue: 0.558, alpha: 1),
//                      NSColor(calibratedRed: 0.483, green: 0.483, blue: 0.483, alpha: 1),
//                      NSColor(calibratedRed: 0.35, green: 0.35, blue: 0.35, alpha: 1)]

        let colors = [NSColor(calibratedRed: 1, green: 0.652, blue: 0, alpha: 1),
                      NSColor(calibratedRed: 0.32, green: 0.584, blue: 0.8, alpha: 1),
                      NSColor(calibratedRed: 0.79, green: 0.372, blue: 0.191, alpha: 1),
                      NSColor(calibratedRed: 0.676, green: 0.537, blue: 0.315, alpha: 1),
                      NSColor(calibratedRed: 0.431, green: 0.701, blue: 0.407, alpha: 1),
                      NSColor(calibratedRed: 0.59, green: 0.544, blue: 0.763, alpha: 1)]

        var counter = 0

        var buttons = effectsContainer.subviews.filter { $0 as? MenuButton != nil }
        buttons.sort { $0.tag < $1.tag }

        for sv in buttons {
            guard let b = sv as? MenuButton else { continue }
            b.bgColor = colors[counter]
            counter += 1
            if counter > colors.count {
                counter = 0
            }
        }
    }

    ////////////////////////////

    func showEffect( at auIndex: Int, state: Bool ) {
        if auIndex > internalManager!.effectsChain.count - 1 {
            AKLog("index is out of range")
            return
        }

        if state {
            // get audio unit at the specified index
            if let au = internalManager?.effectsChain[auIndex] {
                showAudioUnit(au, identifier: auIndex)

            } else {
                AKLog("Nothing at this index")
            }

        } else {
            if let w = getWindowFromIndentifier(auIndex) {
                w.close()
            }
        }
    }

    func handleEffectSelected(_ auname: String, identifier: Int) {
        guard internalManager != nil else { return }
        AKLog("\(identifier) \(auname)")

        if auname == "-" {
            let blankName = "▼ Insert \(identifier + 1)"
            if let button = getEffectsButtonFromIdentifier(identifier) {
                button.state = .off
            }
            if let menu = getMenuFromIdentifier(identifier) {
                selectEffectInMenu(name: "-", identifier: identifier)
                menu.title = blankName
            }
            if let win = getWindowFromIndentifier(identifier) {
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
            button.title = "▶︎ \(name)"
        }

    }

    // MARK: - Build the effects menus
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

            let internalSubmenu = b.menu?.items.filter { $0.title == akInternals }.first

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

    internal func getWindowFromIndentifier(_ tag: Int ) -> NSWindow? {
        let identifier = windowPrefix + String(tag)
        guard let windows = self.view.window?.childWindows else { return nil }
        for w in windows {
            if w.identifier?.rawValue == identifier {
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

        // first we ask the audio unit if it has a view controller
        audioUnit.auAudioUnit.requestViewController { [weak self] viewController in
            var ui = viewController
            guard let strongSelf = self else { return }
            guard let auName = audioUnit.auAudioUnit.audioUnitName else { return }

            DispatchQueue.main.async {
                // if it doesn't - then the host's job is to create one for it
                if ui == nil {
                    //AKLog("No ViewController for \(audioUnit.name )")
                    ui = NSViewController()
                    ui!.view = AudioUnitGenericView(au: audioUnit)
                }

                guard ui != nil else { return }
                let incomingFrame = ui!.view.frame
                AKLog("Audio Unit incoming frame: \(incomingFrame)")

                guard let selfWindow = strongSelf.view.window else { return }

                //let unitWindow = NSWindow(contentViewController: ui!)
                let unitWindowController = AudioUnitGenericWindow(audioUnit: audioUnit)
                guard let unitWindow = unitWindowController.window else { return }

                unitWindow.title = "\(auName)"
                unitWindow.delegate = self
                unitWindow.identifier = NSUserInterfaceItemIdentifier(strongSelf.windowPrefix + String(identifier))

                var windowColor = NSColor.darkGray
                if let buttonColor = strongSelf.getMenuFromIdentifier(identifier)?.bgColor {
                    windowColor = buttonColor
                }

                unitWindowController.scrollView.documentView = ui!.view
                NSLayoutConstraint.activateConstraintsEqualToSuperview(child: ui!.view)
                unitWindowController.toolbar?.backgroundColor = windowColor.withAlphaComponent(0.9)

                if let gauv = ui?.view as? AudioUnitGenericView {
                    gauv.backgroundColor = windowColor
                }

                let toolbarHeight: CGFloat = 20

                let f = NSMakeRect(unitWindow.frame.origin.x,
                                   unitWindow.frame.origin.y,
                                   ui!.view.frame.width,
                                   ui!.view.frame.height + toolbarHeight + 20)
                unitWindow.setFrame(f, display: true)

                let uiFrame = NSMakeRect(0,
                                   0,
                                   incomingFrame.width,
                                   incomingFrame.height + toolbarHeight)
                ui!.view.frame = uiFrame

//                    } else {
//                       unitWindow.contentViewController = ui!
//                    }

                if let w = strongSelf.getWindowFromIndentifier(identifier) {
                    unitWindow.setFrameOrigin( w.frame.origin )
                    w.close()
                }

                selfWindow.addChildWindow(unitWindow, ordered: NSWindow.OrderingMode.above)
                unitWindow.setFrameOrigin(NSPoint(x:selfWindow.frame.origin.x, y:selfWindow.frame.origin.y - unitWindow.frame.height))

                if let button = strongSelf.getEffectsButtonFromIdentifier(identifier) {
                    button.state = .on
                }

            } //dispatch
        }
    }

    fileprivate func reconnect() {
        // is FM playing?
        if fm != nil && fm!.isStarted {
            internalManager!.connectEffects(firstNode: fm!, lastNode: mixer)
            return
        } else if auInstrument != nil && !(player?.isStarted ?? false) {
            internalManager!.connectEffects(firstNode: auInstrument!, lastNode: mixer)
            return
        } else if player != nil {
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

        reconnect()
    }

    func handleEffectRemoved(at auIndex: Int) {
        reconnect()
    }
}
