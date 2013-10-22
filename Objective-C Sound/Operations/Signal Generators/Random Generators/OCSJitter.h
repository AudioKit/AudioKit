//
//  OCSJitter.h
//  Objective-C Sound
//
//  Auto-generated from database on 10/21/13.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSControl.h"
#import "OCSParameter+Operation.h"

/** Generates a segmented line whose segments are randomly generated.
 
 This operation generates a segmented line whose segments are randomly generated inside the interval amplitude to -amplitude. Duration of each segment is a random value generated according to minimum and maximum frequency values.
This can be used to make more natural and “analog-sounding” some static, dull sound. For best results, it is suggested to keep its amplitude moderate.
 */

@interface OCSJitter : OCSControl

/// Instantiates the jitter
/// @param amplitude Amplitude of jitter deviation
/// @param maxFrequency Maximum speed of random frequency variations (expressed in Hz)
/// @param minFrequency Minimum speed of random frequency variations (expressed in Hz)
- (id)initWithAmplitude:(OCSControl *)amplitude
           maxFrequency:(OCSControl *)maxFrequency
           minFrequency:(OCSControl *)minFrequency;

@end