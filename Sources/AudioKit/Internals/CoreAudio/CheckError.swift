// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import os.log
import AVFoundation

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
            AKLog("kAudio_ParamError", log: OSLog.general, type: .error)

        case kAUGraphErr_NodeNotFound:
            AKLog("kAUGraphErr_NodeNotFound", log: OSLog.general, type: .error)

        case kAUGraphErr_OutputNodeErr:
            AKLog("kAUGraphErr_OutputNodeErr", log: OSLog.general, type: .error)

        case kAUGraphErr_InvalidConnection:
            AKLog("kAUGraphErr_InvalidConnection", log: OSLog.general, type: .error)

        case kAUGraphErr_CannotDoInCurrentContext:
            AKLog("kAUGraphErr_CannotDoInCurrentContext", log: OSLog.general, type: .error)

        case kAUGraphErr_InvalidAudioUnit:
            AKLog("kAUGraphErr_InvalidAudioUnit", log: OSLog.general, type: .error)

        case kAudioToolboxErr_InvalidSequenceType:
            AKLog("kAudioToolboxErr_InvalidSequenceType", log: OSLog.general, type: .error)

        case kAudioToolboxErr_TrackIndexError:
            AKLog("kAudioToolboxErr_TrackIndexError", log: OSLog.general, type: .error)

        case kAudioToolboxErr_TrackNotFound:
            AKLog("kAudioToolboxErr_TrackNotFound", log: OSLog.general, type: .error)

        case kAudioToolboxErr_EndOfTrack:
            AKLog("kAudioToolboxErr_EndOfTrack", log: OSLog.general, type: .error)

        case kAudioToolboxErr_StartOfTrack:
            AKLog("kAudioToolboxErr_StartOfTrack", log: OSLog.general, type: .error)

        case kAudioToolboxErr_IllegalTrackDestination:
            AKLog("kAudioToolboxErr_IllegalTrackDestination", log: OSLog.general, type: .error)

        case kAudioToolboxErr_NoSequence:
            AKLog("kAudioToolboxErr_NoSequence", log: OSLog.general, type: .error)

        case kAudioToolboxErr_InvalidEventType:
            AKLog("kAudioToolboxErr_InvalidEventType", log: OSLog.general, type: .error)

        case kAudioToolboxErr_InvalidPlayerState:
            AKLog("kAudioToolboxErr_InvalidPlayerState", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidProperty:
            AKLog("kAudioUnitErr_InvalidProperty", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidParameter:
            AKLog("kAudioUnitErr_InvalidParameter", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidElement:
            AKLog("kAudioUnitErr_InvalidElement", log: OSLog.general, type: .error)

        case kAudioUnitErr_NoConnection:
            AKLog("kAudioUnitErr_NoConnection", log: OSLog.general, type: .error)

        case kAudioUnitErr_FailedInitialization:
            AKLog("kAudioUnitErr_FailedInitialization", log: OSLog.general, type: .error)

        case kAudioUnitErr_TooManyFramesToProcess:
            AKLog("kAudioUnitErr_TooManyFramesToProcess", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidFile:
            AKLog("kAudioUnitErr_InvalidFile", log: OSLog.general, type: .error)

        case kAudioUnitErr_FormatNotSupported:
            AKLog("kAudioUnitErr_FormatNotSupported", log: OSLog.general, type: .error)

        case kAudioUnitErr_Uninitialized:
            AKLog("kAudioUnitErr_Uninitialized", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidScope:
            AKLog("kAudioUnitErr_InvalidScope", log: OSLog.general, type: .error)

        case kAudioUnitErr_PropertyNotWritable:
            AKLog("kAudioUnitErr_PropertyNotWritable", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidPropertyValue:
            AKLog("kAudioUnitErr_InvalidPropertyValue", log: OSLog.general, type: .error)

        case kAudioUnitErr_PropertyNotInUse:
            AKLog("kAudioUnitErr_PropertyNotInUse", log: OSLog.general, type: .error)

        case kAudioUnitErr_Initialized:
            AKLog("kAudioUnitErr_Initialized", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidOfflineRender:
            AKLog("kAudioUnitErr_InvalidOfflineRender", log: OSLog.general, type: .error)

        case kAudioUnitErr_Unauthorized:
            AKLog("kAudioUnitErr_Unauthorized", log: OSLog.general, type: .error)

        default:
            AKLog("\(error)", log: OSLog.general, type: .error)
        }
    #else
        switch error {
        case noErr:
            return
        case kAudio_ParamError:
            AKLog("kAudio_ParamError", log: OSLog.general, type: .error)

        case kAUGraphErr_NodeNotFound:
            AKLog("kAUGraphErr_NodeNotFound", log: OSLog.general, type: .error)

        case kAUGraphErr_OutputNodeErr:
            AKLog("kAUGraphErr_OutputNodeErr", log: OSLog.general, type: .error)

        case kAUGraphErr_InvalidConnection:
            AKLog("kAUGraphErr_InvalidConnection", log: OSLog.general, type: .error)

        case kAUGraphErr_CannotDoInCurrentContext:
            AKLog("kAUGraphErr_CannotDoInCurrentContext", log: OSLog.general, type: .error)

        case kAUGraphErr_InvalidAudioUnit:
            AKLog("kAUGraphErr_InvalidAudioUnit", log: OSLog.general, type: .error)

        case kMIDIInvalidClient:
            AKLog("kMIDIInvalidClient", log: OSLog.midi, type: .error)

        case kMIDIInvalidPort:
            AKLog("kMIDIInvalidPort", log: OSLog.midi, type: .error)

        case kMIDIWrongEndpointType:
            AKLog("kMIDIWrongEndpointType", log: OSLog.midi, type: .error)

        case kMIDINoConnection:
            AKLog("kMIDINoConnection", log: OSLog.midi, type: .error)

        case kMIDIUnknownEndpoint:
            AKLog("kMIDIUnknownEndpoint", log: OSLog.midi, type: .error)

        case kMIDIUnknownProperty:
            AKLog("kMIDIUnknownProperty", log: OSLog.midi, type: .error)

        case kMIDIWrongPropertyType:
            AKLog("kMIDIWrongPropertyType", log: OSLog.midi, type: .error)

        case kMIDINoCurrentSetup:
            AKLog("kMIDINoCurrentSetup", log: OSLog.midi, type: .error)

        case kMIDIMessageSendErr:
            AKLog("kMIDIMessageSendErr", log: OSLog.midi, type: .error)

        case kMIDIServerStartErr:
            AKLog("kMIDIServerStartErr", log: OSLog.midi, type: .error)

        case kMIDISetupFormatErr:
            AKLog("kMIDISetupFormatErr", log: OSLog.midi, type: .error)

        case kMIDIWrongThread:
            AKLog("kMIDIWrongThread", log: OSLog.midi, type: .error)

        case kMIDIObjectNotFound:
            AKLog("kMIDIObjectNotFound", log: OSLog.midi, type: .error)

        case kMIDIIDNotUnique:
            AKLog("kMIDIIDNotUnique", log: OSLog.midi, type: .error)

        case kMIDINotPermitted:
            AKLog("kMIDINotPermitted: Have you enabled the audio background mode in your ios app?",
                  log: OSLog.midi,
                  type: .error)

        case kAudioToolboxErr_InvalidSequenceType:
            AKLog("kAudioToolboxErr_InvalidSequenceType", log: OSLog.general, type: .error)

        case kAudioToolboxErr_TrackIndexError:
            AKLog("kAudioToolboxErr_TrackIndexError", log: OSLog.general, type: .error)

        case kAudioToolboxErr_TrackNotFound:
            AKLog("kAudioToolboxErr_TrackNotFound", log: OSLog.general, type: .error)

        case kAudioToolboxErr_EndOfTrack:
            AKLog("kAudioToolboxErr_EndOfTrack", log: OSLog.general, type: .error)

        case kAudioToolboxErr_StartOfTrack:
            AKLog("kAudioToolboxErr_StartOfTrack", log: OSLog.general, type: .error)

        case kAudioToolboxErr_IllegalTrackDestination:
            AKLog("kAudioToolboxErr_IllegalTrackDestination", log: OSLog.general, type: .error)

        case kAudioToolboxErr_NoSequence:
            AKLog("kAudioToolboxErr_NoSequence", log: OSLog.general, type: .error)

        case kAudioToolboxErr_InvalidEventType:
            AKLog("kAudioToolboxErr_InvalidEventType", log: OSLog.general, type: .error)

        case kAudioToolboxErr_InvalidPlayerState:
            AKLog("kAudioToolboxErr_InvalidPlayerState", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidProperty:
            AKLog("kAudioUnitErr_InvalidProperty", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidParameter:
            AKLog("kAudioUnitErr_InvalidParameter", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidElement:
            AKLog("kAudioUnitErr_InvalidElement", log: OSLog.general, type: .error)

        case kAudioUnitErr_NoConnection:
            AKLog("kAudioUnitErr_NoConnection", log: OSLog.general, type: .error)

        case kAudioUnitErr_FailedInitialization:
            AKLog("kAudioUnitErr_FailedInitialization", log: OSLog.general, type: .error)

        case kAudioUnitErr_TooManyFramesToProcess:
            AKLog("kAudioUnitErr_TooManyFramesToProcess", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidFile:
            AKLog("kAudioUnitErr_InvalidFile", log: OSLog.general, type: .error)

        case kAudioUnitErr_FormatNotSupported:
            AKLog("kAudioUnitErr_FormatNotSupported", log: OSLog.general, type: .error)

        case kAudioUnitErr_Uninitialized:
            AKLog("kAudioUnitErr_Uninitialized", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidScope:
            AKLog("kAudioUnitErr_InvalidScope", log: OSLog.general, type: .error)

        case kAudioUnitErr_PropertyNotWritable:
            AKLog("kAudioUnitErr_PropertyNotWritable", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidPropertyValue:
            AKLog("kAudioUnitErr_InvalidPropertyValue", log: OSLog.general, type: .error)

        case kAudioUnitErr_PropertyNotInUse:
            AKLog("kAudioUnitErr_PropertyNotInUse", log: OSLog.general, type: .error)

        case kAudioUnitErr_Initialized:
            AKLog("kAudioUnitErr_Initialized", log: OSLog.general, type: .error)

        case kAudioUnitErr_InvalidOfflineRender:
            AKLog("kAudioUnitErr_InvalidOfflineRender", log: OSLog.general, type: .error)

        case kAudioUnitErr_Unauthorized:
            AKLog("kAudioUnitErr_Unauthorized", log: OSLog.general, type: .error)

        default:
            AKLog("\(error)", log: OSLog.general, type: .error)
        }
    #endif
}
