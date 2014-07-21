//
//  AKMoogVCF.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A digital emulation of the Moog diode ladder filter configuration.
 
 This emulation is based loosely on the paper “Analyzing the Moog VCF with Considerations for Digital Implementation” by Stilson and Smith (CCRMA). 
 */

@interface AKMoogVCF : AKAudio

/// Instantiates the moog vcf
/// @param audioSource     Input signal.
/// @param cutoffFrequency Filter cut-off frequency in Hz.
/// @param resonance       Amount of resonance. Self-oscillation occurs when this is approximately one.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
                    cutoffFrequency:(AKParameter *)cutoffFrequency
                          resonance:(AKParameter *)resonance;

@end