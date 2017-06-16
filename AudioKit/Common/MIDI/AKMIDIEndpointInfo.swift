//
//  AKMIDIEndpointInfo.swift
//  AudioKit
//
//  Created by dejaWorks on 06/05/2017.
//  Copyright © 2017 AudioKit. All rights reserved.
//

/// MIDI Endpoint Information
public struct EndpointInfo {
    
    /// Unique name
    public var name = ""
    
    /// Dispaly name
    public var displayName = ""
    
    /// Model information
    public var model = ""
    
    /// Manufacturer
    public var manufacturer = ""
    
    /// Image?
    public var image = ""
    
    /// Driver Owner
    public var driverOwner = ""
}

extension Collection where Iterator.Element == MIDIEndpointRef {
    var endpointInfos: [EndpointInfo] {

        let name = map { GetMIDIObjectStringProperty(ref: $0, property: kMIDIPropertyName) }
        let displayName = map { GetMIDIObjectStringProperty(ref: $0, property: kMIDIPropertyDisplayName) }
        let manufacturer = map { GetMIDIObjectStringProperty(ref: $0, property: kMIDIPropertyModel) }
        let model = map { GetMIDIObjectStringProperty(ref: $0, property: kMIDIPropertyManufacturer) }
        let image = map { GetMIDIObjectStringProperty(ref: $0, property: kMIDIPropertyImage) }
        let driverOwner = map { GetMIDIObjectStringProperty(ref: $0, property: kMIDIPropertyDriverOwner) }

        var ei = [EndpointInfo]()
        for i in 0 ..< displayName.count {
            ei.append(EndpointInfo(name: name[i],
                                   displayName: displayName[i],
                                   model: model[i],
                                   manufacturer: manufacturer[i],
                                   image: image[i],
                                   driverOwner: driverOwner[i]))
        }
        return ei
    }
}

extension AKMIDI {

    /// Destinations
    public var destinationInfos: [EndpointInfo] {
        return MIDIDestinations().endpointInfos
    }

    /// Inputs
    public var inputInfos: [EndpointInfo] {
        return MIDISources().endpointInfos
    }
}
