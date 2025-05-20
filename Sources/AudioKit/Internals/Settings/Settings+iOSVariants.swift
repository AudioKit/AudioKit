// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(macOS)

    import AVFoundation
    import Foundation
    import os.log

    public extension Settings {
        /// Global audio format AudioKit will default to for new objects and connections
        /// - Tag: SettingsAudioFormat
        static var audioFormat = defaultAudioFormat {
            didSet {
                do {
                    try AVAudioSession.sharedInstance().setPreferredSampleRate(audioFormat.sampleRate)
                } catch {
                    Log("Could not set preferred sample rate to \(sampleRate) " + error.localizedDescription,
                        log: OSLog.settings,
                        type: .error)
                }
            }
        }

        /// Whether haptics and system sounds are played while a microphone is setup or recording is active
        static var allowHapticsAndSystemSoundsDuringRecording: Bool = false {
            didSet {
                if #available(iOS 13.0, tvOS 13.0, *) {
                    do {
                        try AVAudioSession.sharedInstance()
                            .setAllowHapticsAndSystemSoundsDuringRecording(allowHapticsAndSystemSoundsDuringRecording)
                    } catch {
                        Log("Could not set allow haptics to \(allowHapticsAndSystemSoundsDuringRecording)" +
                            error.localizedDescription, log: OSLog.settings, type: .error)
                    }
                }
            }
        }

        /// Enable AudioKit AVAudioSession Category Management
        static var disableAVAudioSessionCategoryManagement: Bool = false

        /// The hardware ioBufferDuration. Setting this will request the new value, getting
        /// will query the hardware.
        static var ioBufferDuration: Double {
            set {
                do {
                    try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(newValue)

                } catch {
                    Log("Could not set the preferred IO buffer duration to \(newValue): \(error)",
                        log: OSLog.settings,
                        type: .error)
                }
            }
            get {
                return AVAudioSession.sharedInstance().ioBufferDuration
            }
        }

        /// Checks the application's info.plist to see if UIBackgroundModes includes "audio".
        /// If background audio is supported then the system will allow the AVAudioEngine to start even if
        /// the app is in, or entering, a background state. This can help prevent a potential crash
        /// (AVAudioSessionErrorCodeCannotStartPlaying aka error code 561015905) when a route/category change causes
        /// AudioEngine to attempt to start while the app is not active and background audio is not supported.
        static let appSupportsBackgroundAudio = (
            Bundle.main.infoDictionary?["UIBackgroundModes"] as? [String])?.contains("audio") ?? false

        /// Shortcut for AVAudioSession.sharedInstance()
        static let session = AVAudioSession.sharedInstance()

        /// Convenience method accessible from Objective-C
        static func setSession(category: SessionCategory, options: UInt) throws {
            try setSession(category: category, with: AVAudioSession.CategoryOptions(rawValue: options))
        }

        /// Set the audio session type
        static func setSession(category: SessionCategory,
                               with options: AVAudioSession.CategoryOptions = []) throws
        {
            guard Settings.disableAVAudioSessionCategoryManagement == false else { return }

            try session.setCategory(category.avCategory, mode: .default, options: options)

            // Core Haptics
            do {
                if #available(iOS 13.0, tvOS 13.0, *) {
                    try session.setAllowHapticsAndSystemSoundsDuringRecording(
                        allowHapticsAndSystemSoundsDuringRecording
                    )
                }
            } catch {
                Log("Could not allow haptics: \(error)", log: OSLog.settings, type: .error)
            }

            try session.setPreferredIOBufferDuration(bufferLength.duration)
            try session.setActive(true)
        }

        /// Checks if headphones are connected
        /// Returns true if headPhones are connected, otherwise return false
        static var headPhonesPlugged: Bool {
            let headphonePortTypes: [AVAudioSession.Port] =
                [.headphones, .bluetoothHFP, .bluetoothA2DP]
            return session.currentRoute.outputs.contains {
                headphonePortTypes.contains($0.portType)
            }
        }

        /// Enum of available AVAudioSession Categories
        enum SessionCategory: Int, CustomStringConvertible {
            /// Audio silenced by silent switch and screen lock - audio is mixable
            case ambient
            /// Audio is silenced by silent switch and screen lock - audio is non mixable
            case soloAmbient
            /// Audio is not silenced by silent switch and screen lock - audio is non mixable
            case playback
            /// Silences playback audio
            case record
            /// Audio is not silenced by silent switch and screen lock - audio is non mixable.
            /// To allow mixing see AVAudioSessionCategoryOptionMixWithOthers.
            case playAndRecord
            #if !os(tvOS)
                /// Disables playback and recording; deprecated in iOS 10, unavailable on tvOS
                case audioProcessing
            #endif
            /// Use to multi-route audio. May be used on input, output, or both.
            case multiRoute

            /// Printout string
            public var description: String {
                switch self {
                case .ambient:
                    return AVAudioSession.Category.ambient.rawValue
                case .soloAmbient:
                    return AVAudioSession.Category.soloAmbient.rawValue
                case .playback:
                    return AVAudioSession.Category.playback.rawValue
                case .record:
                    return AVAudioSession.Category.record.rawValue
                case .playAndRecord:
                    return AVAudioSession.Category.playAndRecord.rawValue
                case .multiRoute:
                    return AVAudioSession.Category.multiRoute.rawValue
                #if !os(tvOS)
                    default:
                        return AVAudioSession.Category.soloAmbient.rawValue
                #endif
                }
            }

            /// AV Audio Session Category
            public var avCategory: AVAudioSession.Category {
                switch self {
                case .ambient:
                    return .ambient
                case .soloAmbient:
                    return .soloAmbient
                case .playback:
                    return .playback
                case .record:
                    return .record
                case .playAndRecord:
                    return .playAndRecord
                case .multiRoute:
                    return .multiRoute
                #if !os(tvOS)
                    default:
                        return .soloAmbient
                #endif
                }
            }
        }
    }

#endif
