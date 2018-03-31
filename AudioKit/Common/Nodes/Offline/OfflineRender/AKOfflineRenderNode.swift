//
//  AKOfflineRenderNode.swift
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

@available(iOS, obsoleted: 11)
@available(tvOS, obsoleted: 11)
@available(macOS, obsoleted: 10.13)
open class AKOfflineRenderNode: AKNode, AKComponent, AKInput {

    public typealias AKAudioUnitType = AKOfflineRenderAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "mnrn")
    private var internalAU: AKAudioUnitType?

    open var internalRenderEnabled: Bool {
        get { return internalAU!.internalRenderEnabled }
        set { internalAU!.internalRenderEnabled = newValue }
    }

    open func renderToURL(_ url: URL, seconds: Double, settings: [String: Any]? = nil) throws {
        return try internalAU!.render(toFile: url, seconds: seconds, settings: settings)
    }
    open func renderToBuffer(seconds: Double) throws -> AVAudioPCMBuffer {
        return try internalAU!.render(toBuffer: seconds)
    }
    @objc public init(_ input: AKNode? = nil) {

        _Self.register()
        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioNode = avAudioUnit
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: strongSelf)
        }
    }

}
