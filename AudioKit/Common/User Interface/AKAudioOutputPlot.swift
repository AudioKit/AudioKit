//
//  AKAudioOutputPlot.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka on 12/9/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

import Foundation

@objc public class AKAudioOutputPlot: EZAudioPlot {
    public func setupNode() {
        AKManager.sharedInstance.engine.outputNode.installTapOnBus(0, bufferSize: bufferSize, format: nil) { [weak self] (buffer, time) -> Void in
            if let strongSelf = self {
                buffer.frameLength = strongSelf.bufferSize;
                let offset: Int = Int(buffer.frameCapacity - buffer.frameLength);
                let tail = buffer.floatChannelData[0];
                strongSelf.updateBuffer(&tail[offset],
                    withBufferSize: strongSelf.bufferSize);
            }
        }
    }

    
    let bufferSize: UInt32 = 512
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNode()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNode()
    }
}