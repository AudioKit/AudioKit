//
//  CheckError.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

// Print out a more human readable error message
///
/// - parameter error: OSStatus flag
///
public func CheckError(_ error: OSStatus) {
    switch error {
    case noErr:
        return
    case kAudio_ParamError:
        AKLog("Error: kAudio_ParamError \n")
        
    case kAUGraphErr_NodeNotFound:
        AKLog("Error: kAUGraphErr_NodeNotFound \n")
        
    case kAUGraphErr_OutputNodeErr:
        AKLog( "Error: kAUGraphErr_OutputNodeErr \n")
        
    case kAUGraphErr_InvalidConnection:
        AKLog("Error: kAUGraphErr_InvalidConnection \n")
        
    case kAUGraphErr_CannotDoInCurrentContext:
        AKLog( "Error: kAUGraphErr_CannotDoInCurrentContext \n")
        
    case kAUGraphErr_InvalidAudioUnit:
        AKLog( "Error: kAUGraphErr_InvalidAudioUnit \n")
        
    case kMIDIInvalidClient :
        AKLog( "kMIDIInvalidClient ")
        
    case kMIDIInvalidPort :
        AKLog( "Error: kMIDIInvalidPort ")
        
    case kMIDIWrongEndpointType :
        AKLog( "Error: kMIDIWrongEndpointType")
        
    case kMIDINoConnection :
        AKLog( "Error: kMIDINoConnection ")
        
    case kMIDIUnknownEndpoint :
        AKLog( "Error: kMIDIUnknownEndpoint ")
        
    case kMIDIUnknownProperty :
        AKLog( "Error: kMIDIUnknownProperty ")
        
    case kMIDIWrongPropertyType :
        AKLog( "Error: kMIDIWrongPropertyType ")
        
    case kMIDINoCurrentSetup :
        AKLog( "Error: kMIDINoCurrentSetup ")
        
    case kMIDIMessageSendErr :
        AKLog( "kError: MIDIMessageSendErr ")
        
    case kMIDIServerStartErr :
        AKLog( "kError: MIDIServerStartErr ")
        
    case kMIDISetupFormatErr :
        AKLog( "Error: kMIDISetupFormatErr ")
        
    case kMIDIWrongThread :
        AKLog( "Error: kMIDIWrongThread ")
        
    case kMIDIObjectNotFound :
        AKLog( "Error: kMIDIObjectNotFound ")
        
    case kMIDIIDNotUnique :
        AKLog( "Error: kMIDIIDNotUnique ")
        
    case kMIDINotPermitted:
        AKLog( "Error: kMIDINotPermitted: Have you enabled the audio background mode in your ios app?")
        
    case kAudioToolboxErr_InvalidSequenceType :
        AKLog( "Error: kAudioToolboxErr_InvalidSequenceType ")
        
    case kAudioToolboxErr_TrackIndexError :
        AKLog( "Error: kAudioToolboxErr_TrackIndexError ")
        
    case kAudioToolboxErr_TrackNotFound :
        AKLog( "Error: kAudioToolboxErr_TrackNotFound ")
        
    case kAudioToolboxErr_EndOfTrack :
        AKLog( "Error: kAudioToolboxErr_EndOfTrack ")
        
    case kAudioToolboxErr_StartOfTrack :
        AKLog( "Error: kAudioToolboxErr_StartOfTrack ")
        
    case kAudioToolboxErr_IllegalTrackDestination :
        AKLog( "Error: kAudioToolboxErr_IllegalTrackDestination")
        
    case kAudioToolboxErr_NoSequence :
        AKLog( "Error: kAudioToolboxErr_NoSequence ")
        
    case kAudioToolboxErr_InvalidEventType :
        AKLog( "Error: kAudioToolboxErr_InvalidEventType")
        
    case kAudioToolboxErr_InvalidPlayerState :
        AKLog( "Error: kAudioToolboxErr_InvalidPlayerState")
        
    case kAudioUnitErr_InvalidProperty :
        AKLog( "Error: kAudioUnitErr_InvalidProperty")
        
    case kAudioUnitErr_InvalidParameter :
        AKLog( "Error: kAudioUnitErr_InvalidParameter")
        
    case kAudioUnitErr_InvalidElement :
        AKLog( "Error: kAudioUnitErr_InvalidElement")
        
    case kAudioUnitErr_NoConnection :
        AKLog( "Error: kAudioUnitErr_NoConnection")
        
    case kAudioUnitErr_FailedInitialization :
        AKLog( "Error: kAudioUnitErr_FailedInitialization")
        
    case kAudioUnitErr_TooManyFramesToProcess :
        AKLog( "Error: kAudioUnitErr_TooManyFramesToProcess")
        
    case kAudioUnitErr_InvalidFile :
        AKLog( "Error: kAudioUnitErr_InvalidFile")
        
    case kAudioUnitErr_FormatNotSupported :
        AKLog( "Error: kAudioUnitErr_FormatNotSupported")
        
    case kAudioUnitErr_Uninitialized :
        AKLog( "Error: kAudioUnitErr_Uninitialized")
        
    case kAudioUnitErr_InvalidScope :
        AKLog( "Error: kAudioUnitErr_InvalidScope")
        
    case kAudioUnitErr_PropertyNotWritable :
        AKLog( "Error: kAudioUnitErr_PropertyNotWritable")
        
    case kAudioUnitErr_InvalidPropertyValue :
        AKLog( "Error: kAudioUnitErr_InvalidPropertyValue")
        
    case kAudioUnitErr_PropertyNotInUse :
        AKLog( "Error: kAudioUnitErr_PropertyNotInUse")
        
    case kAudioUnitErr_Initialized :
        AKLog( "Error: kAudioUnitErr_Initialized")
        
    case kAudioUnitErr_InvalidOfflineRender :
        AKLog( "Error: kAudioUnitErr_InvalidOfflineRender")
        
    case kAudioUnitErr_Unauthorized :
        AKLog( "Error: kAudioUnitErr_Unauthorized")
        
    default:
        AKLog("Error: \(error)")
    }
}
