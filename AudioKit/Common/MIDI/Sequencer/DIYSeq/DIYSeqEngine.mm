//
//  DIYSeqEngine.m
//  AudioKit
//
//  Created by Jeff Cooper on 1/25/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//
#import <AudioKit/AudioKit-Swift.h>

#import "DIYSeqEngine.h"
#import "DIYSeqDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKDIYSeqEngine {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKDIYSeqEngineDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

-(void)setLoopEnabled:(bool)loopEnabled {
    _kernel.loopEnabled = loopEnabled;
}
-(bool)loopEnabled {
    return _kernel.loopEnabled;
}
-(void)setTarget:(AudioUnit)target {
    _kernel.setTargetAU(target);
}
-(void)addMIDIEvent:(uint8_t)status data1:(uint8_t)data1 data2:(uint8_t)data2 beat:(double)beat {
    _kernel.addMIDIEvent(status, data1, data2, beat);
}
-(void)setLoopCallback:(AKCCallback)callback {
    _kernel.loopCallback = callback;
}

standardKernelPassthroughs()

- (void)createParameters {

    standardGeneratorSetup(DIYSeqEngine)

    // Create a parameter object for the start.
    AUParameter *startPointAUParameter = [AUParameter parameterWithIdentifier:@"startPoint"
                                                                         name:@"startPoint"
                                                                      address:startPointAddress
                                                                          min:0
                                                                          max:1
                                                                         unit:kAudioUnitParameterUnit_Generic];
    // Initialize the parameter values.
    startPointAUParameter.value = 0;

    _kernel.setParameter(startPointAddress,   startPointAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree treeWithChildren:@[
                                                         startPointAUParameter
                                                         ]];

    parameterTreeBlock(DIYSeqEngine)
}

AUAudioUnitGeneratorOverrides(DIYSeqEngine)

@end
