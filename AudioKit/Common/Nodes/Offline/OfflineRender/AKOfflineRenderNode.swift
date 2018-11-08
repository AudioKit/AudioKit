//
//  AKOfflineRenderNode.swift
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Node to render audio quickly into a buffer of memory or into a file
@available(iOS, obsoleted: 11)
@available(tvOS, obsoleted: 11)
@available(macOS, obsoleted: 10.13)
open class AKOfflineRenderNode: AKNode, AKComponent, AKInput {

    public typealias AKAudioUnitType = AKOfflineRenderAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "mnrn")
    private var internalAU: AKAudioUnitType?

    /// Turn on or off internal rendering
    open var internalRenderEnabled: Bool {
        get { return internalAU!.internalRenderEnabled }
        set { internalAU!.internalRenderEnabled = newValue }
    }

    /// Render audio to a file given by a URL
    ///
    /// Parameters:
    ///   - url: URL of the file to write the audio to
    ///   - duration: length of time to record, in seconds
    ///   - settings: Dictionary of information about the file to write
    ///
    @objc public func renderToURL(_ url: URL, duration: Double, settings: [String: Any]? = nil) throws {
        return try internalAU!.render(toFile: url, duration: duration, settings: settings)
    }

    /// Render audio to memory
    ///
    /// - parameter duration: length of audio buffer, seconds
    ///
    @objc public func renderToBuffer(for duration: Double) throws -> AVAudioPCMBuffer {
        return try internalAU!.render(toBuffer: duration)
    }

    /// Initialize the offline rendering of a specific node
    ///
    /// - parameter input: AudioKit Node to render audio from
    ///
    @objc public init(_ input: AKNode? = nil) {

        _Self.register()
        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioUnit = avAudioUnit
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: strongSelf)
        }
    }

}
