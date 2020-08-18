// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(macOS)

import Foundation
import AVFoundation
import os.log

    extension AKSettings {
        /// Global audio format AudioKit will default to for new objects and connections
        public static var audioFormat = defaultAudioFormat {
            didSet {
                do {
                    try AVAudioSession.sharedInstance().setPreferredSampleRate(audioFormat.sampleRate)
                } catch {
                    AKLog("Could not set preferred sample rate to \(sampleRate) " + error.localizedDescription,
                          log: OSLog.settings,
                          type: .error)
                }
            }
        }

        /// Whether haptics and system sounds are played while a microphone is setup or recording is active
        public static var allowHapticsAndSystemSoundsDuringRecording: Bool = false {
            didSet {
                if #available(iOS 13.0, tvOS 13.0, *) {
                    do {
                        try AVAudioSession.sharedInstance()
                            .setAllowHapticsAndSystemSoundsDuringRecording(allowHapticsAndSystemSoundsDuringRecording)
                    } catch {
                        AKLog("Could not set allow haptics to \(allowHapticsAndSystemSoundsDuringRecording)" +
                            error.localizedDescription, log: OSLog.settings, type: .error)
                    }
                }
            }
        }

        /// Enable AudioKit AVAudioSession Category Management
        public static var disableAVAudioSessionCategoryManagement: Bool = false

        /// If set to true, AudioKit will not deactivate the AVAudioSession when stopping
        public static var disableAudioSessionDeactivationOnStop: Bool = false

        /// If set to false, AudioKit will not handle the AVAudioSession route change
        /// notification (AVAudioSessionRouteChange) and will not restart the AVAudioEngine
        /// instance when such notifications are posted. The developer can instead subscribe
        /// to these notifications and restart AudioKit after rebuilding their audio chain.
        public static var enableRouteChangeHandling: Bool = true

        /// Whether to allow audio playback to override the mute setting
        public static var playbackWhileMuted: Bool = false

        /// Whether we will allow our audio to mix with other applications
        public static var mixWithOthers: Bool = true

        /// Whether to output to the speaker (rather than receiver) when audio input is enabled
        public static var defaultToSpeaker: Bool = false

        /// Whether to use bluetooth when audio input is enabled
        public static var useBluetooth: Bool = false

        /// Whether AirPlay is enabled when audio input is enabled
        public static var allowAirPlay: Bool = false

        /// Additional control over the options to use for bluetooth
        public static var bluetoothOptions: AVAudioSession.CategoryOptions = []

        /// Enable / disable voice processing (echo canellation)
        public static var enableEchoCancellation: Bool = false

        /// The hardware ioBufferDuration. Setting this will request the new value, getting
        /// will query the hardware.
        public static var ioBufferDuration: Double {
            set {
                do {
                    try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(newValue)

                } catch {
                    AKLog("Could not set the preferred IO buffer duration to \(newValue): \(error)",
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
        public static let appSupportsBackgroundAudio = (
            Bundle.main.infoDictionary?["UIBackgroundModes"] as? [String])?.contains("audio") ?? false

        /// Shortcut for AVAudioSession.sharedInstance()
        public static let session = AVAudioSession.sharedInstance()

        /// Convenience method accessible from Objective-C
        public static func setSession(category: SessionCategory, options: UInt) throws {
            try setSession(category: category, with: AVAudioSession.CategoryOptions(rawValue: options))
        }

        /// Set the audio session type
        public static func setSession(category: SessionCategory,
                                      with options: AVAudioSession.CategoryOptions = []) throws {
            guard AKSettings.disableAVAudioSessionCategoryManagement == false else { return }

            do {
                try AKTry {
                    if #available(iOS 10.0, *) {
                        try session.setCategory(category.avCategory, mode: .default, options: options)
                    } else {
                        session.perform(NSSelectorFromString("setCategory:error:"), with: category.avCategory)
                    }
                }
            } catch let error as NSError {
                AKLog("Cannot set AVAudioSession Category to \(category) " +
                      "with options: \(options) " + error.localizedDescription,
                      log: OSLog.settings,
                      type: .error)
                throw error
            }

            // Core Haptics
            do {
                if #available(iOS 13.0, tvOS 13.0, *) {
                    try session.setAllowHapticsAndSystemSoundsDuringRecording(
                        allowHapticsAndSystemSoundsDuringRecording
                    )
                }
            } catch {
                AKLog("Could not allow haptics: \(error)", log: OSLog.settings, type: .error)
            }

            // Preferred IO Buffer Duration
            do {
                try AKTry {
                    try session.setPreferredIOBufferDuration(bufferLength.duration)
                }
            } catch let error as NSError {
                AKLog("Cannot set Preferred IO Buffer Duration to " +
                    "\(bufferLength.duration) ( = \(bufferLength.samplesCount) samples) due to " +
                    error.localizedDescription, log: OSLog.settings, type: .error)
                throw error
            }

            // Activate session
            do {
                try AKTry {
                    try session.setActive(true)
                }
            } catch let error as NSError {
                AKLog("Cannot set AVAudioSession.setActive to true \(error)", log: OSLog.settings, type: .error)
                throw error
            }
        }

        public static func computedSessionCategory() -> SessionCategory {
            if AKSettings.audioInputEnabled {
                return .playAndRecord
            } else if AKSettings.playbackWhileMuted {
                return .playback
            } else {
                return .ambient
            }
        }

        public static func computedSessionOptions() -> AVAudioSession.CategoryOptions {
            var options: AVAudioSession.CategoryOptions = []

            if AKSettings.mixWithOthers {
                options = options.union(.mixWithOthers)
            }

            if AKSettings.audioInputEnabled {
                #if !os(tvOS)
                    if #available(iOS 10.0, *) {
                        // Blueooth Options
                        // .allowBluetooth can only be set with the categories .playAndRecord and .record
                        // .allowBluetoothA2DP comes for free if the category is .ambient, .soloAmbient, or
                        // .playback. This option is cleared if the category is .record, or .multiRoute. If this
                        // option and .allowBluetooth are set and a device supports Hands-Free Profile (HFP) and the
                        // Advanced Audio Distribution Profile (A2DP), the Hands-Free ports will be given a higher
                        // priority for routing.
                        if !AKSettings.bluetoothOptions.isEmpty {
                            options = options.union(AKSettings.bluetoothOptions)
                        } else if AKSettings.useBluetooth {
                            // If bluetoothOptions aren't specified
                            // but useBluetooth is then we will use these defaults
                            options = options.union([.allowBluetooth,
                                                     .allowBluetoothA2DP])
                        }

                        // AirPlay
                        if AKSettings.allowAirPlay {
                            options = options.union(.allowAirPlay)
                        }
                    } else if !AKSettings.bluetoothOptions.isEmpty ||
                        AKSettings.useBluetooth ||
                        AKSettings.allowAirPlay {
                        AKLog("Some of the specified AKSettings are not supported by iOS 9 and were ignored.")
                    }

                    // Default to Speaker
                    if AKSettings.defaultToSpeaker {
                        options = options.union(.defaultToSpeaker)
                    }

                #endif
            }

            return options
        }

        /// Checks if headphones are connected
        /// Returns true if headPhones are connected, otherwise return false
        public static var headPhonesPlugged: Bool {
            let headphonePortTypes: [AVAudioSession.Port] =
                [.headphones, .bluetoothHFP, .bluetoothA2DP]
            return session.currentRoute.outputs.contains {
                headphonePortTypes.contains($0.portType)
            }
        }

        /// Enum of available AVAudioSession Categories
        public enum SessionCategory: Int, CustomStringConvertible {
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
                default:
                    return AVAudioSession.Category.soloAmbient.rawValue
                }
            }

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
                default:
                    return .soloAmbient
                }
            }
        }
    }

#endif
