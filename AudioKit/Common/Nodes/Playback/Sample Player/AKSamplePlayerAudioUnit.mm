//
//  AKSamplePlayerAudioUnit.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#import "AKSamplePlayerAudioUnit.h"
#import "AKSamplePlayerDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

#import <AudioKit/AudioKit-Swift.h>

@implementation AKSamplePlayerAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKSamplePlayerDSPKernel _kernel;
    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setStartPoint:(float)startPoint {
    _kernel.setStartPoint(startPoint);
}
- (void)setEndPoint:(float)endPoint {
    _kernel.setEndPoint(endPoint);
}
- (void)setRate:(float)rate {
    _kernel.setRate(rate);
}
- (void)setLoop:(BOOL)loopOnOff {
    _kernel.setLoop(loopOnOff);
}

- (void)setupAudioFileTable:(float *)data size:(UInt32)size {
    _kernel.setUpTable(data, size);
}
- (int)size {
    return _kernel.ftbl_size;
}
standardKernelPassthroughs()

- (void)createParameters {

    standardSetup(SamplePlayer)
    
    // Create a parameter object for the start.
    AUParameter *startPointAUParameter = [AUParameter parameter:@"startPoint"
                                                           name:@"startPoint"
                                                        address:startPointAddress
                                                            min:0
                                                            max:1
                                                           unit:kAudioUnitParameterUnit_Generic];
    
    // Create a parameter object for the endPoint.
    AUParameter *endPointAUParameter = [AUParameter parameter:@"endPoint"
                                                           name:@"endPoint"
                                                        address:endPointAddress
                                                            min:0
                                                            max:1
                                                           unit:kAudioUnitParameterUnit_Generic];
    
    // Create a parameter object for the rate.
    AUParameter *rateAUParameter = [AUParameter parameter:@"rate"
                                                     name:@"rate. A value of. 1  normal, 2 is double speed, 0.5 is halfspeed, etc."
                                                  address:rateAddress
                                                      min:0
                                                      max:10
                                                     unit:kAudioUnitParameterUnit_Generic];

    // Initialize the parameter values.
    startPointAUParameter.value = 0;
    endPointAUParameter.value = 1;
    rateAUParameter.value = 1;

    _kernel.setParameter(startPointAddress,   startPointAUParameter.value);
    _kernel.setParameter(endPointAddress,  endPointAUParameter.value);
    _kernel.setParameter(rateAddress, rateAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree tree:@[
        startPointAUParameter,
        endPointAUParameter,
        rateAUParameter
    ]];

	parameterTreeBlock(SamplePlayer)
}

AUAudioUnitGeneratorOverrides(SamplePlayer)

@end


