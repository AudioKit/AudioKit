//
//  AKOfflineRenderNode.swift
//  AudioKit
//
//  Created by David O'Neill on 8/7/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

open class AKOfflineRenderNode: AKNode, AKComponent, AKInput {

    public typealias AKAudioUnitType = AKOfflineRenderAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "mnrn")
    private var internalAU: AKAudioUnitType?

    open var internalRenderEnabled: Bool {
        get { return internalAU!.internalRenderEnabled }
        set { internalAU!.internalRenderEnabled = newValue }
    }

    open func renderToURL(_ url: URL, seconds: Double, settings: [String : Any]? = nil) throws {
        return try internalAU!.render(toFile: url, seconds: seconds, settings: settings)
    }
    open func renderToBuffer(seconds: Double) throws -> AVAudioPCMBuffer {
        return try internalAU!.render(toBuffer:seconds)
    }
    public init(_ input: AKNode? = nil) {

        _Self.register()
        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: self!)
        }
    }

}
