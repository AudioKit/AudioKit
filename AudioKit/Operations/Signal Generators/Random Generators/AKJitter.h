//
//  AKJitter.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 10/21/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Generates a segmented line whose segments are randomly generated.
 
 This operation generates a segmented line whose segments are randomly generated inside the interval amplitude to -amplitude. Duration of each segment is a random value generated according to minimum and maximum frequency values.
 This can be used to make more natural and “analog-sounding” some static, dull sound. For best results, it is suggested to keep its amplitude moderate.
 */

@interface AKJitter : AKControl

/// Instantiates the jitter
/// @param amplitude Amplitude of jitter deviation
/// @param minFrequency Minimum speed of random frequency variations (expressed in Hz)
/// @param maxFrequency Maximum speed of random frequency variations (expressed in Hz)
- (instancetype)initWithAmplitude:(AKControl *)amplitude
                     minFrequency:(AKControl *)minFrequency
                     maxFrequency:(AKControl *)maxFrequency;

@end