// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import os.log

// Print out a more human readable error message
///
/// - parameter error: OSStatus flag
///
public func CheckError(_ error: OSStatus) {
    #if os(tvOS) // No CoreMIDI
        switch error {
        case noErr:
            return
        case kAudio_ParamError:
            Log("kAudio_ParamError", log: OSLog.general, type: .error)

        case kAUGraphErr_NodeNotFound:
            Log("kAUGraphErr_NodeNotFound", log: OSLog.general, type: .error)

        case kAUGraphErr_OutputNodeErr:
            Log("kAUGraphErr_OutputNodeErr", log: OSLog.general, type: .error)

        case kAUGraphErr_InvalidConnection:
            Log("kAUGraphErr_InvalidConnection", log: OSLog.general, type: .error)

        case kAUGraphErr_CannotDoInCurrentContext:
            Log("kAUGraphErr_CannotDoInCurrentContext", log: OSLog.general, type: .error)

        case kAUGraphErr_InvalidAudioUnit:
            Log("kAUGraphErr_InvalidAudioUnit", log: OSLog.general, type: .error)

        case kAudioToolboxErr_InvalidSequenceType:
            Log("kAudioToolboxErr_InvalidSequenceType", log: OSLog.general, type: .error)

        case kAudioToolboxErr_TrackIndexError:
            Log("kAudioToolboxErr_TrackIndexError", log: OSLog.general, type: .error)

        case kAudioToolboxErr_TrackNotFound:
            Log("kAudioToolboxErr_TrackNotFound", log: OSLog.general, type: .error)

        case kAudioToolboxErr_EndOfTrack:
            Log("kAudioToolboxErr_EndOfTrack", log: OSLog.general, type: .error)

        case kAudioToolboxErr_StartOfTrack:
            Log("kAudioToolboxErr_StartOfTrack", log: OSLog.general, type: .error)

        case kAudioToolboxErr_IllegalTrackDestination:
            Log("kAudioToolboxErr_IllegalTrackDestination", log: OSLog.general, type: .error)

        case kAudioToolboxErr_NoSequence:
            Log("kAudioToolboxErr_NoSequence", log: OSLog.general, type: .error)

        case kAudioToolboxErr_InvalidEventType:
            Log("kAudioToolboxErr_InvalidEventType", log: OSLog.general, type: .error)

        case kAudioToolboxErr_InvalidPlayerState:
            Log("kAudioToolboxErr_InvalidPlayerState", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidProperty:
            Log("kAudioUnitErr_InvalidProperty", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidParameter:
            Log("kAudioUnitErr_InvalidParameter", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidElement:
            Log("kAudioUnitErr_InvalidElement", log: OSLog.general, type: .error)

        case kAudioUnitErr_NoConnection:
            Log("kAudioUnitErr_NoConnection", log: OSLog.general, type: .error)

        case kAudioUnitErr_FailedInitialization:
            Log("kAudioUnitErr_FailedInitialization", log: OSLog.general, type: .error)

        case kAudioUnitErr_TooManyFramesToProcess:
            Log("kAudioUnitErr_TooManyFramesToProcess", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidFile:
            Log("kAudioUnitErr_InvalidFile", log: OSLog.general, type: .error)

        case kAudioUnitErr_FormatNotSupported:
            Log("kAudioUnitErr_FormatNotSupported", log: OSLog.general, type: .error)

        case kAudioUnitErr_Uninitialized:
            Log("kAudioUnitErr_Uninitialized", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidScope:
            Log("kAudioUnitErr_InvalidScope", log: OSLog.general, type: .error)

        case kAudioUnitErr_PropertyNotWritable:
            Log("kAudioUnitErr_PropertyNotWritable", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidPropertyValue:
            Log("kAudioUnitErr_InvalidPropertyValue", log: OSLog.general, type: .error)

        case kAudioUnitErr_PropertyNotInUse:
            Log("kAudioUnitErr_PropertyNotInUse", log: OSLog.general, type: .error)

        case kAudioUnitErr_Initialized:
            Log("kAudioUnitErr_Initialized", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidOfflineRender:
            Log("kAudioUnitErr_InvalidOfflineRender", log: OSLog.general, type: .error)

        case kAudioUnitErr_Unauthorized:
            Log("kAudioUnitErr_Unauthorized", log: OSLog.general, type: .error)

        default:
            Log("\(error)", log: OSLog.general, type: .error)
        }
    #else
        switch error {
        case noErr:
            return
        case kAudio_ParamError:
            Log("kAudio_ParamError", log: OSLog.general, type: .error)

        case kAUGraphErr_NodeNotFound:
            Log("kAUGraphErr_NodeNotFound", log: OSLog.general, type: .error)

        case kAUGraphErr_OutputNodeErr:
            Log("kAUGraphErr_OutputNodeErr", log: OSLog.general, type: .error)

        case kAUGraphErr_InvalidConnection:
            Log("kAUGraphErr_InvalidConnection", log: OSLog.general, type: .error)

        case kAUGraphErr_CannotDoInCurrentContext:
            Log("kAUGraphErr_CannotDoInCurrentContext", log: OSLog.general, type: .error)

        case kAUGraphErr_InvalidAudioUnit:
            Log("kAUGraphErr_InvalidAudioUnit", log: OSLog.general, type: .error)

        case kMIDIInvalidClient:
            Log("kMIDIInvalidClient", log: OSLog.midi, type: .error)

        case kMIDIInvalidPort:
            Log("kMIDIInvalidPort", log: OSLog.midi, type: .error)

        case kMIDIWrongEndpointType:
            Log("kMIDIWrongEndpointType", log: OSLog.midi, type: .error)

        case kMIDINoConnection:
            Log("kMIDINoConnection", log: OSLog.midi, type: .error)

        case kMIDIUnknownEndpoint:
            Log("kMIDIUnknownEndpoint", log: OSLog.midi, type: .error)

        case kMIDIUnknownProperty:
            Log("kMIDIUnknownProperty", log: OSLog.midi, type: .error)

        case kMIDIWrongPropertyType:
            Log("kMIDIWrongPropertyType", log: OSLog.midi, type: .error)

        case kMIDINoCurrentSetup:
            Log("kMIDINoCurrentSetup", log: OSLog.midi, type: .error)

        case kMIDIMessageSendErr:
            Log("kMIDIMessageSendErr", log: OSLog.midi, type: .error)

        case kMIDIServerStartErr:
            Log("kMIDIServerStartErr", log: OSLog.midi, type: .error)

        case kMIDISetupFormatErr:
            Log("kMIDISetupFormatErr", log: OSLog.midi, type: .error)

        case kMIDIWrongThread:
            Log("kMIDIWrongThread", log: OSLog.midi, type: .error)

        case kMIDIObjectNotFound:
            Log("kMIDIObjectNotFound", log: OSLog.midi, type: .error)

        case kMIDIIDNotUnique:
            Log("kMIDIIDNotUnique", log: OSLog.midi, type: .error)

        case kMIDINotPermitted:
            Log("kMIDINotPermitted: Have you enabled the audio background mode in your ios app?",
                  log: OSLog.midi,
                  type: .error)

        case kAudioToolboxErr_InvalidSequenceType:
            Log("kAudioToolboxErr_InvalidSequenceType", log: OSLog.general, type: .error)

        case kAudioToolboxErr_TrackIndexError:
            Log("kAudioToolboxErr_TrackIndexError", log: OSLog.general, type: .error)

        case kAudioToolboxErr_TrackNotFound:
            Log("kAudioToolboxErr_TrackNotFound", log: OSLog.general, type: .error)

        case kAudioToolboxErr_EndOfTrack:
            Log("kAudioToolboxErr_EndOfTrack", log: OSLog.general, type: .error)

        case kAudioToolboxErr_StartOfTrack:
            Log("kAudioToolboxErr_StartOfTrack", log: OSLog.general, type: .error)

        case kAudioToolboxErr_IllegalTrackDestination:
            Log("kAudioToolboxErr_IllegalTrackDestination", log: OSLog.general, type: .error)

        case kAudioToolboxErr_NoSequence:
            Log("kAudioToolboxErr_NoSequence", log: OSLog.general, type: .error)

        case kAudioToolboxErr_InvalidEventType:
            Log("kAudioToolboxErr_InvalidEventType", log: OSLog.general, type: .error)

        case kAudioToolboxErr_InvalidPlayerState:
            Log("kAudioToolboxErr_InvalidPlayerState", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidProperty:
            Log("kAudioUnitErr_InvalidProperty", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidParameter:
            Log("kAudioUnitErr_InvalidParameter", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidElement:
            Log("kAudioUnitErr_InvalidElement", log: OSLog.general, type: .error)

        case kAudioUnitErr_NoConnection:
            Log("kAudioUnitErr_NoConnection", log: OSLog.general, type: .error)

        case kAudioUnitErr_FailedInitialization:
            Log("kAudioUnitErr_FailedInitialization", log: OSLog.general, type: .error)

        case kAudioUnitErr_TooManyFramesToProcess:
            Log("kAudioUnitErr_TooManyFramesToProcess", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidFile:
            Log("kAudioUnitErr_InvalidFile", log: OSLog.general, type: .error)

        case kAudioUnitErr_FormatNotSupported:
            Log("kAudioUnitErr_FormatNotSupported", log: OSLog.general, type: .error)

        case kAudioUnitErr_Uninitialized:
            Log("kAudioUnitErr_Uninitialized", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidScope:
            Log("kAudioUnitErr_InvalidScope", log: OSLog.general, type: .error)

        case kAudioUnitErr_PropertyNotWritable:
            Log("kAudioUnitErr_PropertyNotWritable", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidPropertyValue:
            Log("kAudioUnitErr_InvalidPropertyValue", log: OSLog.general, type: .error)

        case kAudioUnitErr_PropertyNotInUse:
            Log("kAudioUnitErr_PropertyNotInUse", log: OSLog.general, type: .error)

        case kAudioUnitErr_Initialized:
            Log("kAudioUnitErr_Initialized", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidOfflineRender:
            Log("kAudioUnitErr_InvalidOfflineRender", log: OSLog.general, type: .error)

        case kAudioUnitErr_Unauthorized:
            Log("kAudioUnitErr_Unauthorized", log: OSLog.general, type: .error)

        default:
            Log("\(error)", log: OSLog.general, type: .error)
        }
    #endif
}
