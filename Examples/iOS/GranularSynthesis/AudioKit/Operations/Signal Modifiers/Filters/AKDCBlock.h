//
//  AKDCBlock.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A DC blocking filter.
 
 {"Implements the DC blocking filter"=>"Y[i] = X[i] - X[i-1] + (igain * Y[i-1])  Based on work by Perry Cook."}
 */

@interface AKDCBlock : AKAudio

/// Instantiates the dc block
/// @param audioSource Input audio signal.
- (instancetype)initWithAudioSource:(AKAudio *)audioSource;


/// Set an optional gain
/// @param gain The gain of the filter, which defaults to 0.99.
- (void)setOptionalGain:(AKConstant *)gain;


@end