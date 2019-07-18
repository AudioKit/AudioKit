//
//  AKWaveTableAudioUnit.mm
//  AudioKit
//
//  Created by Jeff Cooper, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
#import <AudioKit/AudioKit-Swift.h>

#import "AKWaveTableAudioUnit.h"
#import "AKWaveTableDSPKernel.hpp"

#import "BufferedAudioBus.hpp"

@implementation AKWaveTableAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKWaveTableDSPKernel _kernel;
    BufferedOutputBus _outputBusBuffer;
}
@synthesize parameterTree = _parameterTree;

- (void)setStartPoint:(float)startPoint {
    _kernel.setStartPoint(startPoint);
}
- (void)setEndPoint:(float)endPoint {
    _kernel.setEndPoint(endPoint);
}
- (void)setTempStartPoint:(float)startPoint {
    _kernel.setTempStartPoint(startPoint);
}
- (void)setTempEndPoint:(float)endPoint {
    _kernel.setTempEndPoint(endPoint);
}
- (void)setLoopStartPoint:(float)startPoint {
    _kernel.setLoopStartPoint(startPoint);
}
- (void)setLoopEndPoint:(float)endPoint {
    _kernel.setLoopEndPoint(endPoint);
}
-(void)setCompletionHandler:(AKCCallback)handler {
    _kernel.completionHandler = handler;
}
-(void)setLoadCompletionHandler:(AKCCallback)handler {
    _kernel.loadCompletionHandler = handler;
}
-(void)setLoopCallback:(AKCCallback)callback {
    _kernel.loopCallback = callback;
}
- (void)setLoop:(BOOL)loopOnOff {
    _kernel.setLoop(loopOnOff);
}
- (void)setRate:(double)rate {
    _kernel.setRate(rate);
}
- (void)setVolume:(float)volume {
    _kernel.setVolume(volume);
}
- (void)setupAudioFileTable:(UInt32)size {
    _kernel.setUpTable(size);
}
- (void)loadAudioData:(float *)data size:(UInt32)size sampleRate:(float)sampleRate numChannels:(UInt32)numChannels {
    _kernel.loadAudioData(data, size, sampleRate, numChannels);
}
- (int)size {
    return _kernel.ftbl_size;
}
- (double)position {
    float normalized = (_kernel.position - _kernel.startPointViaRate()) / (_kernel.endPointViaRate() - _kernel.startPointViaRate());
    return _kernel.rate > 0 ? normalized : 1 - normalized;
}

- (void)destroy {
    _kernel.destroy();
}

standardKernelPassthroughs()

- (void)createParameters {

    standardGeneratorSetup(WaveTable)

    // Create a parameter object for the start.
    AUParameter *startPointAUParameter = [AUParameter parameterWithIdentifier:@"startPoint"
                                                           name:@"startPoint"
                                                        address:startPointAddress
                                                            min:0
                                                            max:1
                                                           unit:kAudioUnitParameterUnit_Generic];

    // Create a parameter object for the endPoint.
    AUParameter *endPointAUParameter = [AUParameter parameterWithIdentifier:@"endPoint"
                                                         name:@"endPoint"
                                                      address:endPointAddress
                                                          min:0
                                                          max:1
                                                         unit:kAudioUnitParameterUnit_Generic];

    // Create a parameter object for the loop start.
    AUParameter *loopStartPointAUParameter = [AUParameter parameterWithIdentifier:@"loopStartPoint"
                                                           name:@"loopStartPoint"
                                                        address:loopStartPointAddress
                                                            min:0
                                                            max:1
                                                           unit:kAudioUnitParameterUnit_Generic];

    // Create a parameter object for the loop endPoint.
    AUParameter *loopEndPointAUParameter = [AUParameter parameterWithIdentifier:@"loopEndPoint"
                                                         name:@"loopEndPoint"
                                                      address:loopEndPointAddress
                                                          min:0
                                                          max:1
                                                         unit:kAudioUnitParameterUnit_Generic];

    // Create a parameter object for the rate.
    AUParameter *rateAUParameter = [AUParameter parameterWithIdentifier:@"rate"
                                                     name:@"rate. A value of 1 is normal, 2 is double speed, 0.5 is halfspeed, etc."
                                                  address:rateAddress
                                                      min:-10
                                                      max:10
                                                     unit:kAudioUnitParameterUnit_Generic];

    // Create a parameter object for the volume.
    AUParameter *volumeAUParameter = [AUParameter parameterWithIdentifier:@"volume"
                                                       name:@"volume"
                                                    address:volumeAddress
                                                        min:0
                                                        max:10
                                                       unit:kAudioUnitParameterUnit_Generic];
    // Initialize the parameter values.
    startPointAUParameter.value = 0;
    endPointAUParameter.value = 1;
    loopStartPointAUParameter.value = 0;
    loopEndPointAUParameter.value = 1;
    rateAUParameter.value = 1;
    volumeAUParameter.value = 1;

    _kernel.setParameter(startPointAddress,   startPointAUParameter.value);
    _kernel.setParameter(endPointAddress,  endPointAUParameter.value);
    _kernel.setParameter(loopStartPointAddress,   loopStartPointAUParameter.value);
    _kernel.setParameter(loopEndPointAddress,  loopEndPointAUParameter.value);
    _kernel.setParameter(rateAddress, rateAUParameter.value);
    _kernel.setParameter(volumeAddress, volumeAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree treeWithChildren:@[
                                             startPointAUParameter,
                                             endPointAUParameter,
                                             loopStartPointAUParameter,
                                             loopEndPointAUParameter,
                                             rateAUParameter,
                                             volumeAUParameter
                                             ]];

    parameterTreeBlock(WaveTable)
}

AUAudioUnitGeneratorOverrides(WaveTable)

@end


