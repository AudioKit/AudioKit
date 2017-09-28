//
//  GainAudioUnit.mm
//  AudioKit
//
//  Created by Andrew Voelkel on 8/29/17.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#import "GainAudioUnit.h"
#import "BufferedAudioBus.hpp"

/**
 This class is demo a butt simple AudioUnit built using the underlying AudioUnitBase class, 
 which is designed to minimize the work needed at this level. All this audio unit is adjust gain.
 As such it only has one parameter Gain.
 */

#define kGain 0

@implementation GainAudioUnit

@synthesize gain = _gain;

-(void) setGain: (float) gain {
    _gain = gain;
    [self setParameterWithAddress:kGain value:gain];
}

-(float) gain { return _gain; }

/**
 This method is used by the base class to initialize the underlying C++ DSP used by the render
 thread. This is necessary because the base class doesn't know the type of the C++ DSP, it only 
 knows the C++ base class.
 
 I think that ultimately the code at this level can be in Swift. The only tricky part is getting
 a pointer to the DSP, since Swift doesn't have C++ interop at present. But there is a workaround
 for that.
 */

-(void*)initDspWithSampleRate:(double) sampleRate channelCount:(AVAudioChannelCount) count {
    AK4GainEffectDsp* kernel = new AK4GainEffectDsp();
    kernel->init(sampleRate, count);
    return (void*)kernel;
}

/** 
 All this method needs to do is set up parameters. The rest is taken care of by the base class.
 */

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
                                     options:(AudioComponentInstantiationOptions)options
                                       error:(NSError **)outError {
    
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    if (self == nil) { return nil; }
    
    // Create a parameter object for the gain.
    AUParameter *gain = [AUParameterTree createParameterWithIdentifier:@"gain" name:@"Gain"
                                                               address:kGain
                                                                   min:0.0 max:10.0
                                                                  unit:kAudioUnitParameterUnit_LinearGain
                                                              unitName:nil
                                                                 flags:kAudioUnitParameterFlag_IsReadable |
                                                                       kAudioUnitParameterFlag_IsWritable |
                                                                       kAudioUnitParameterFlag_CanRamp
                                                          valueStrings:nil
                                                   dependentParameters:nil];
    
    
    
    // Create the parameter tree.
    [self setParameterTree: [AUParameterTree createTreeWithChildren:@[gain]]];

    // Initialize default parameter values.
    gain.value = 1.0;  // Since the observer is setup, this should trigger a call to the DSP
    return self;
}

- (BOOL)canProcessInPlace {
    return YES;
}

@end
