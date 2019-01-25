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
    MIDIPortRef _midiPort;
    MIDIEndpointRef _midiEndpoint;
    struct MIDIEvent _events[512];
    int _noteCount;
    double _beatsPerSample;
    double _sampleRate;
    double _lengthInBeats;
    uint _playCount;
    uint _maximumPlayCount;
    BOOL _stopAfterCurrentNotes;
    Float64 _startOffset;
    Float64 _lastStartSample; //Used for detecting sequence loopback
    bool _isPlaying;
    AudioUnit _audioUnit;
}
@synthesize parameterTree = _parameterTree;

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
