//
//  AKAudioUnitBase.h
//  AudioKit
//
//  Created by Andrew Voelkel, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AKDSPBase.hpp"

@interface AKAudioUnitBase : AUAudioUnit

/**
 This method should be overridden by the specific AU code, because it knows how to set up
 the DSP code. It should also be declared as public in the h file, but that causes problems
 because Swift wants to process as a bridging header, and it doesn't understand what a DSPBase
 is. I'm not sure the standard way to deal with this.
 */

- (void*)initDSPWithSampleRate:(double) sampleRate channelCount:(AVAudioChannelCount) count;

/**
 Sets the parameter tree. The important piece here is that setting the parameter tree
 triggers the setup of the blocks for observer, provider, and string representation. See
 the .m file. There may be a better way to do what is needed here.
 */

- (void) setParameterTree: (AUParameterTree*) tree;

- (float) getParameterWithAddress:(AUParameterAddress)address;
- (void) setParameterWithAddress:(AUParameterAddress)address value:(AUValue)value;
- (void) setParameterImmediatelyWithAddress:(AUParameterAddress)address value:(AUValue)value;

// Add for compatibility with AKAudioUnit

- (void)start;
- (void)stop;
- (void)clear;
- (void)initializeConstant:(AUValue)value;

// Common for oscillating effects
- (void)setupWaveform:(int)size;
- (void)setWaveformValue:(float)value atIndex:(UInt32)index;

@property (readonly) BOOL isPlaying;
@property (readonly) BOOL isSetUp;

// These three properties are what are in the Apple example code.

@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray;

@end


