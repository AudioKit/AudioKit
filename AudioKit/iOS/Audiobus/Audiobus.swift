//
//  Audiobus.swift
//  AudioKit
//
//  Created by Daniel Clelland on 2/06/16.
//  Updated for AudioKit 3 by Aurelius Prochazka.
//
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AudioKit
import CoreAudio

class Audiobus {
    
    // MARK: Client
    
    static var client: Audiobus?
    
    // MARK: Actions
    
    static func start() {
        guard client == nil else {
            return
        }
        
        if let apiKey = apiKey {
            client = Audiobus(apiKey: apiKey)
        }
    }

    private static var apiKey: String? {
        guard let path = Bundle.main.path(forResource: "Audiobus", ofType: "txt") else {
            return nil
        }
        do {
            return try String(contentsOfFile: path).replacingOccurrences(of: "\n", with: "")
        } catch {
            return nil
        }
    }
    
    // MARK: Initialization
    
    var controller: ABAudiobusController
    
    var audioUnit: AudioUnit {
        return AudioKit.engine.outputNode.audioUnit!
    }
    
    init(apiKey: String) {
        self.controller = ABAudiobusController(apiKey: apiKey)

        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource:"Info", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            for component in dict["AudioComponents"] as [[String: AnyObject]] {
                let type = fourCC(component["type"] as String)
                let subtype = fourCC(component["subtype"] as String)
                let name = component["name"] as String
                let manufacturer = fourCC(component["manufacturer"] as String)
                
                if type == kAudioUnitType_RemoteInstrument ||
                    type == kAudioUnitType_RemoteGenerator {
                    self.controller.addSenderPort(
                        ABSenderPort(
                            name: name,
                            title: name,
                            audioComponentDescription: AudioComponentDescription(
                                componentType: type,
                                componentSubType: subtype,
                                componentManufacturer: manufacturer,
                                componentFlags: 0,
                                componentFlagsMask: 0
                            ),
                            audioUnit: audioUnit
                        )
                    )
                }
                if type == kAudioUnitType_RemoteEffect {
                    self.controller.addFilterPort(
                        ABFilterPort(
                            name: name,
                            title: name,
                            audioComponentDescription: AudioComponentDescription(
                                componentType: type,
                                componentSubType: subtype,
                                componentManufacturer: manufacturer,
                                componentFlags: 0,
                                componentFlagsMask: 0
                            ),
                            audioUnit: audioUnit
                        )
                    )
                }
            }
        }
        
        startObservingInterAppAudioConnections()
        startObservingAudiobusConnections()
    }
    
    deinit {
        stopObservingInterAppAudioConnections()
        stopObservingAudiobusConnections()
    }
    
    // MARK: Properties
    
    var isConnected: Bool {
        return controller.isConnectedToAudiobus || audioUnit.isConnectedToInterAppAudio
    }
    
    var isConnectedToInput: Bool {
        return controller.isConnectedToAudiobus(portOfType: ABPortTypeSender) || audioUnit.isConnectedToInterAppAudio(nodeOfType: kAudioUnitType_RemoteEffect)
    }
    
    // MARK: Connections
    
    private var audioUnitPropertyListener: AudioUnitPropertyListener!
    
    private func startObservingInterAppAudioConnections() {
        audioUnitPropertyListener = AudioUnitPropertyListener { (_, _) in
            self.updateConnections()
        }
        
        audioUnit.add(listener: audioUnitPropertyListener, toProperty: kAudioUnitProperty_IsInterAppConnected)
    }
    
    private func stopObservingInterAppAudioConnections() {
        audioUnit.remove(listener: self.audioUnitPropertyListener, fromProperty: kAudioUnitProperty_IsInterAppConnected)
    }
    
    private func startObservingAudiobusConnections() {
        let _ = NotificationCenter.default.addObserver(forName: NSNotification.Name.ABConnectionsChanged, object: nil, queue: nil, using: { _ in
            self.updateConnections()
        })
    }
    
    private func stopObservingAudiobusConnections() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.ABConnectionsChanged, object: nil)
    }
    
    private func updateConnections() {
        if isConnected {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "IAAConnected"), object: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "IAADisconnected"), object: nil)
        }
    }
    
}

private extension ABAudiobusController {
    
    var isConnectedToAudiobus: Bool {
        return connected && memberOfActiveAudiobusSession
    }
    
    func isConnectedToAudiobus(portOfType type: ABPortType) -> Bool {
        guard connectedPorts != nil else {
            return false
        }
        
        return connectedPorts.flatMap { $0 as? ABPort }.filter { $0.type == type }.isEmpty == false
    }
    
}

private extension AudioUnit {
    
    var isConnectedToInterAppAudio: Bool {
        let value: UInt32 = getValue(forProperty: kAudioUnitProperty_IsInterAppConnected)
        return value != 0
    }
    
    func isConnectedToInterAppAudio(nodeOfType type: OSType) -> Bool {
        let value: AudioComponentDescription = getValue(forProperty: kAudioOutputUnitProperty_NodeComponentDescription)
        return value.componentType == type
    }
    
}
