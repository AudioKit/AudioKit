//
//  AKMIDIEndpointInfo.swift
//  AudioKit
//
//  Created by dejaWorks, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// MIDI Endpoint Information
<<<<<<< HEAD


public struct EndpointInfo:Hashable, Codable {
=======
public struct EndpointInfo:Hashable {
>>>>>>> Get/Open/Close Input|Outputs with EndpointInfo object. (in progress...)

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

    /// MIDIUniqueID
    public var midiUniqueID: MIDIUniqueID

    /// MIDIEndpointRef
<<<<<<< HEAD
    public var midiEndpointRef: MIDIEndpointRef

    /// MIDIPortRef (this will be set|unset when input|output open|close)
    public var midiPortRef: MIDIPortRef?

=======
    public var midiEndpointRef:MIDIEndpointRef
    
    /// MIDIPortRef (this will be set|unset when input|output open|close)
    public var midiPortRef:MIDIPortRef?
    
>>>>>>> Get/Open/Close Input|Outputs with EndpointInfo object. (in progress...)
    /// Equatable
    public static func == (lhs: EndpointInfo, rhs: EndpointInfo) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    /// Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(displayName)
        hasher.combine(model)
        hasher.combine(manufacturer)
        hasher.combine(image)
        hasher.combine(driverOwner)
        hasher.combine(midiUniqueID)
<<<<<<< HEAD
        hasher.combine(midiPortRef)
    }

=======
        // midiPortRef is not added into the hash because midiPortRef is changing with every app launch
    }
>>>>>>> Get/Open/Close Input|Outputs with EndpointInfo object. (in progress...)
    
    /// init
    public init(name: String,
         displayName: String,
         model: String,
         manufacturer: String,
         image: String,
         driverOwner: String,
         midiUniqueID:  MIDIUniqueID,
         midiEndpointRef: MIDIEndpointRef,
         midiPortRef: MIDIPortRef? = nil ) {
        self.name = name
        self.displayName = displayName
        self.model = model
        self.manufacturer = manufacturer
        self.image = image
        self.driverOwner = driverOwner
        self.midiUniqueID = midiUniqueID
        self.midiEndpointRef = midiEndpointRef
        self.midiPortRef = midiPortRef
    }
}

extension Collection where Iterator.Element == MIDIEndpointRef {
    var endpointInfos: [EndpointInfo] {
        return self.map { (element: MIDIEndpointRef) -> EndpointInfo in
            EndpointInfo(
                name:
                    getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyName),
                displayName:
                    getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyDisplayName),
                model:
                    getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyModel),
                manufacturer:
                    getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyManufacturer),
                image:
                    getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyImage),
                driverOwner:
                    getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyDriverOwner),
                midiUniqueID:
                    getMIDIObjectIntegerProperty(ref: element, property: kMIDIPropertyUniqueID),
                midiEndpointRef: element
            )
        }
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
