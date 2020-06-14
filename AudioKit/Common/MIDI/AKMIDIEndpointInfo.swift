// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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
    public var midiEndpointRef: MIDIEndpointRef

    
    /// MIDIUniqueID
    public var midiUniqueID:MIDIUniqueID
    
    /// MIDIEndpointRef
    public var midiEndpointRef:MIDIEndpointRef
    
    
}

extension Collection where Iterator.Element == MIDIEndpointRef {
    var endpointInfos: [EndpointInfo] {
        return self.map { element -> EndpointInfo in
            EndpointInfo(name: getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyName),
                         displayName: getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyDisplayName),
                         model: getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyModel),
                         manufacturer: getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyManufacturer),
                         image: getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyImage),
                         driverOwner: getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyDriverOwner),
                         midiEndpointRef: element as MIDIEndpointRef)
        
        return self.map { (element:MIDIEndpointRef) -> EndpointInfo in
            EndpointInfo(
                name:          getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyName),
                displayName:   getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyDisplayName),
                model:         getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyModel),
                manufacturer:  getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyManufacturer),
                image:         getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyImage),
                driverOwner:   getMIDIObjectStringProperty(ref: element, property: kMIDIPropertyDriverOwner),
                midiUniqueID:  getMIDIObjectIntegerProperty(ref: element, property: kMIDIPropertyUniqueID),
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
