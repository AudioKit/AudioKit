//
//  AKMandolin.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** An emulation of a mandolin.
 
 A mandolin emulation with amplitude, frequency, tuning, gain and mandolin size parameters.
 */

@interface AKMandolin : AKAudio

/// Instantiates the mandolin
/// @param bodySize The size of the body of the mandolin. Range 0 to 2.
/// @param frequency Frequency of note played.
/// @param pairedStringDetuning The proportional detuning between the two strings. Suggested range 0.9 to 1.
/// @param pluckPosition The pluck position, in range 0 to 1. Suggest 0.4.
/// @param loopGain The loop gain of the model, in the range 0.97 to 1.
/// @param amplitude Amplitude of note.
- (instancetype)initWithBodySize:(AKControl *)bodySize
                       frequency:(AKControl *)frequency
            pairedStringDetuning:(AKControl *)pairedStringDetuning
                   pluckPosition:(AKControl *)pluckPosition
                        loopGain:(AKControl *)loopGain
                       amplitude:(AKControl *)amplitude;

@end