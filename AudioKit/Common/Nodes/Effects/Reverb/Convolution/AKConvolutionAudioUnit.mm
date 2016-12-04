//
//  AKConvolutionAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

#import "AKConvolutionAudioUnit.h"
#import "AKConvolutionDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKConvolutionAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKConvolutionDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setupAudioFileTable:(float *)data size:(UInt32)size {
    _kernel.setUpTable(data, size);
}

- (void)setPartitionLength:(int)partitionLength {
    _kernel.setPartitionLength(partitionLength);
}
- (void)start {
    _kernel.start();
}

- (void)stop {
    _kernel.stop();
}

- (BOOL)isPlaying {
    return _kernel.started;
}

- (BOOL)isSetUp {
    return _kernel.resetted;
}

- (void)createParameters {
    standardSetup(Convolution)

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[]];

	parameterTreeBlock(Convolution)
}

AUAudioUnitOverrides(Convolution);

@end


