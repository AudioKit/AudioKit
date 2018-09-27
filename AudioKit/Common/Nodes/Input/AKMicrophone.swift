//
//  AKMicrophone.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Audio from the standard input
open class AKMicrophone: AKNode, AKToggleable {

    internal let mixer = AVAudioMixerNode()

    /// Output Volume (Default 1)
    @objc open dynamic var volume: Double = 1.0 {
        didSet {
            volume = max(volume, 0)
            mixer.outputVolume = Float(volume)
        }
    }

    /// Set the actual microphone device
    public func setDevice(_ device: AKDevice) throws {
        do {
            try AudioKit.setInputDevice(device)
        } catch {
            AKLog("Could not set input device")
        }
    }

    fileprivate var lastKnownVolume: Double = 1.0

    /// Determine if the microphone is currently on.
    @objc open dynamic var isStarted: Bool {
        return volume != 0.0
    }

    /// Initialize the microphone
    override public init() {
        super.init()
        self.avAudioNode = mixer

        AKSettings.audioInputEnabled = true

        // Manually doing the connection since .connect(to:) doesn't support format arguments yet
        #if os(iOS)
        let format = setFormatForDevice()
        AudioKit.engine.attach(self.avAudioNode)
        AudioKit.engine.connect(AudioKit.engine.inputNode, to: self.avAudioNode, format: format!)
        #elseif !os(tvOS)
        AudioKit.engine.inputNode.connect(to: self.avAudioNode)
        #endif
    }

    deinit {
        AKSettings.audioInputEnabled = false
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        if isStopped {
            volume = lastKnownVolume
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        if isPlaying {
            lastKnownVolume = volume
            volume = 0
        }
    }

    // Iphone 6s and up have the hardware mic locked at 48k. This causes issues because AudioKit natively wants to run at 44.1k
    // Here we detect the type of device, so we can set the entire session to 48k if needed
    private func getIphoneType() -> String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        return identifier
    }

    // Here is where we actually check the device type and make the settings, if needed
    private func setFormatForDevice() -> AVAudioFormat? {
        #if os(iOS)
        var desiredFS = AudioKit.engine.inputNode.inputFormat(forBus: 0).sampleRate
        let typeString = getIphoneType()
        let stringArray = typeString.components(separatedBy: CharacterSet.decimalDigits.inverted)
        if let firstNumber = stringArray.first(where: { Int($0) != nil }), let number = Int(firstNumber), number > 7,
            let inFirst = AVAudioSession.sharedInstance().currentRoute.inputs.first,
            let outFirst = AVAudioSession.sharedInstance().currentRoute.outputs.first,
            inFirst.portType == .builtInMic,
            (outFirst.portType == .builtInSpeaker || outFirst.portType == .builtInReceiver)
        {
            desiredFS = 48000.0
            AKSettings.sampleRate = 48000.0
        }
        #else
        let desiredFS = AKSettings.sampleRate
        #endif
        return AVAudioFormat(standardFormatWithSampleRate: desiredFS, channels: 2)
    }
}
