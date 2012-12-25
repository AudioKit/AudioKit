//
//  OCSDCBlock.h
//  Objective-C Sound
//
//  Auto-generated from database on 12/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** A DC blocking filter.
 
 {"Implements the DC blocking filter"=>"Y[i] = X[i] - X[i-1] + (igain * Y[i-1])  Based on work by Perry Cook."}
 */

@interface OCSDCBlock : OCSAudio

/// Instantiates the dc block
/// @param audioSource Input audio signal.
- (id)initWithAudioSource:(OCSAudio *)audioSource


/// Set an optional gain
/// @param gain The gain of the filter, which defaults to 0.99.
- (void)setOptionalGain:(OCSConstant *)gain;


@end