//
//  AudioUnitBase.m
//  TryAVAudioEngine
//
//  Created by Andrew Voelkel on 11/19/16.
//  Copyright © 2016 Andrew Voelkel. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AK4DspBase.hpp"

@interface AK4AudioUnitBase : AUAudioUnit

@property float rampTime;  // Do we really want this at this level?

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


