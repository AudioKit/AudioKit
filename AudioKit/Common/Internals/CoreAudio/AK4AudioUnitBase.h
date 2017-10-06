//
//  AudioUnitBase.m
//  AudioKit
//
//  Created by Andrew Voelkel on 11/19/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AK4DspBase.hpp"

@interface AK4AudioUnitBase : AUAudioUnit

/**
 This method should be overridden by the specific AU code, because it knows how to set up
 the DSP code. It should also be declared as public in the h file, but that causes problems
 because Swift wants to process as a bridging header, and it doesn't understand what a DspBase
 is. I'm not sure the standard way to deal with this.
 */

- (void*)initDspWithSampleRate:(double) sampleRate channelCount:(AVAudioChannelCount) count;

/**
 Sets the parameter tree. The important piece here is that setting the parameter tree
 triggers the setup of the blocks for observer, provider, and string representation. See
 the .m file. There may be a better way to do what is needed here.
 */

- (void) setParameterTree: (AUParameterTree*) tree;

- (float) getParameterWithAddress:(AUParameterAddress)address;
- (void) setParameterWithAddress:(AUParameterAddress)address value:(AUValue)value;


// Add for compatibility with AKAudioUnit

- (void)start;
- (void)stop;
- (BOOL)isPlaying;
- (BOOL)isSetUp;

// These three properties are what are in the Apple example code.

@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray;

@end


