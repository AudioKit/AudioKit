//
//  AKOfflineOutput.swift
//  AudioKit For iOS
//
//  Created by Bang Means Do It on 27/03/2017.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import AVFoundation

open class AKOfflineRender: AKNode, AKComponent {
    public typealias AKAudioUnitType = AKOfflineRenderAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "ofrd")
    
    // MARK: - Properties
    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?
    
    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }
    
    // MARK: - Initialization
    
    /// Initialize this envelope node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///
    public init(_ input: AKNode) {
        
        _Self.register()
        super.init()
        
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self]
            avAudioUnit in
            
            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
            
            input.addConnectionPoint(self!)
        }
    }
    
    // MARK: - Set up
    open func setUpOutputFile(outputFileURL: URL) {
        let cfOutputFileURL = outputFileURL as CFURL!
        
        // Set up audio file to write to
        self.internalAU?.setUpAudioOutput(cfOutputFileURL)
    }
    
    // MARK: - Render
    open func enableOfflineRender(_ enable:Bool) {
        self.internalAU?.enableOfflineRender(enable)
    }
    
    open func completeFileWrite() {
        // Complete the file write
        self.internalAU?.completeFileWrite()
    }
}
