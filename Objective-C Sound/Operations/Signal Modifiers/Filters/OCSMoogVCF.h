//
//  OCSMoogVCF.h
//  Objective-C Sound
//
//  Auto-generated from database on 12/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** A digital emulation of the Moog diode ladder filter configuration.
 
 This emulation is based loosely on the paper “Analyzing the Moog VCF with Considerations for Digital Implementation” by Stilson and Smith (CCRMA). This version was originally coded in Csound by Josep Comajuncosas. Some modifications and conversion to C were done by Hans Mikelson and then adjusted.
 */

@interface OCSMoogVCF : OCSAudio

/// Instantiates the moog vcf
/// @param audioSource Input signal.
/// @param cutoffFrequency Filter cut-off frequency in Hz.
/// @param resonance Amount of resonance. Self-oscillation occurs when this is approximately one.
- (id)initWithAudioSource:(OCSAudio *)audioSource
          cutoffFrequency:(OCSParameter *)cutoffFrequency
                resonance:(OCSParameter *)resonance;

@end