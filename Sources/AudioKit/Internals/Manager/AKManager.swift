// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import CoreAudioKit
#endif

import Dispatch

import AVFoundation

public typealias AKCallback = () -> Void

/// Function type for MIDI callbacks
public typealias AKMIDICallback = (MIDIByte, MIDIByte, MIDIByte) -> Void

/// Top level AudioKit managing class
public class AKManager: NSObject {
    #if !os(macOS)
    public static let deviceSampleRate = AVAudioSession.sharedInstance().sampleRate
    #else
    public static let deviceSampleRate: Double = 44_100
    #endif

    // MARK: - Internal audio engine mechanics

    /// Reference to the AV Audio Engine
    public static var engine: AVAudioEngine {
        get {
            // Access a few attributes immediately so things are initialized properly
            #if !os(tvOS)
            if AKSettings.audioInputEnabled {
                _ = _engine.inputNode
            }
            #endif
            _ = AKManager.deviceSampleRate
            return _engine
        }
        set {
            _engine = newValue
        }
    }

    internal static var _engine = AVAudioEngine()

}
