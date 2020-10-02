// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
/// MIDI Endpoint Information

import AVFoundation

/// Information about a MIDI Endpoint
public struct EndpointInfo: Hashable, Codable {

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
    public var midiEndpointRef: MIDIEndpointRef

    /// MIDIPortRef (this will be set|unset when input|output open|close)
    public var midiPortRef: MIDIPortRef?

    /// Equatable
    public static func == (lhs: EndpointInfo, rhs: EndpointInfo) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    /// Conform to hashable
    /// - Parameter hasher: Hasher to use
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(displayName)
        hasher.combine(model)
        hasher.combine(manufacturer)
        hasher.combine(image)
        hasher.combine(driverOwner)
        hasher.combine(midiUniqueID)
        hasher.combine(midiPortRef)
    }

    /// Initialize this endpoint
    /// - Parameters:
    ///   - name: Unique name
    ///   - displayName: Display Name
    ///   - model: Model description
    ///   - manufacturer: Manufacturer description
    ///   - image: Image
    ///   - driverOwner: Driver owner descriptions
    ///   - midiUniqueID: MIDI Unique ID
    ///   - midiEndpointRef: MIDI Endpoint reference
    ///   - midiPortRef: MIDI Port Reference
    public init(name: String,
                displayName: String,
                model: String,
                manufacturer: String,
                image: String,
                driverOwner: String,
                midiUniqueID: MIDIUniqueID,
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

extension MIDI {
    /// Destinations
    public var destinationInfos: [EndpointInfo] {
        return MIDIDestinations().endpointInfos
    }

    /// Inputs
    public var inputInfos: [EndpointInfo] {
        return MIDISources().endpointInfos
    }
}

#endif
