//
//  AKFilePlayer.swift
//  AudioKit For iOS
//
//  Created by Bang Means Do It on 28/03/2017.
//  Copyright © 2017 AudioKit. All rights reserved.
//

open class AKFilePlayer: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKFilePlayerAudioUnit
    public static let ComponentDescription = AudioComponentDescription(generator: "bfpl")
    
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
    public init(_ inputFileURL:URL) {
        
        _Self.register()
        super.init()
        
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self]
            avAudioUnit in
            
            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }
        
        // Create a URL to output the file to
        let cfInputFileURL = inputFileURL as CFURL
        
        print("Reading from: \(cfInputFileURL)")
        
        // Set up audio file to write to
        self.internalAU?.setUpAudioInput(cfInputFileURL)
    }
    
    // MARK: - Control
    
    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        self.internalAU!.start()
    }
    
    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        self.internalAU!.stop()
    }
    
    open func setSampleTimeStartOffset(_ offset:Int) {
        self.internalAU?.setSampleTimeStartOffset(Int32(offset))
    }
    
    open func fileLengthInSeconds() -> Float {
        return self.internalAU!.fileLengthInSeconds();
    }
    
    open func replace(file inputFileURL:URL) {
        // Create a URL to output the file to
        let cfInputFileURL = inputFileURL as CFURL
        
        print("Reading from: \(cfInputFileURL)")
        
        // Set up audio file to write to
        self.internalAU?.setUpAudioInput(cfInputFileURL)
    }
    
    open func resetToStart() {
        self.internalAU?.prepareToPlay()
        self.internalAU?.start()
    }
    
    open func prepareForOfflineRender() {
        self.internalAU?.prepareForOfflineRender()
    }
}
