//
//  AKDCBlock.h
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** A DC blocking filter.

 {"Implements the DC blocking filter"=>"Y[i] = X[i] - X[i-1] + (igain * Y[i-1])  Based on work by Perry Cook."}
 */

@interface AKDCBlock : AKAudio
/// Instantiates the dc block with all values
/// @param audioSource Input audio signal. [Default Value: ]
/// @param gain The gain of the filter, which defaults to 0.99. [Default Value: 0.99]
- (instancetype)initWithAudioSource:(AKParameter *)audioSource
                               gain:(AKConstant *)gain;

/// Instantiates the dc block with default values
/// @param audioSource Input audio signal.
- (instancetype)initWithAudioSource:(AKParameter *)audioSource;

/// Instantiates the dc block with default values
/// @param audioSource Input audio signal.
+ (instancetype)audioWithAudioSource:(AKParameter *)audioSource;

/// The gain of the filter, which defaults to 0.99. [Default Value: 0.99]
@property AKConstant *gain;

/// Set an optional gain
/// @param gain The gain of the filter, which defaults to 0.99. [Default Value: 0.99]
- (void)setOptionalGain:(AKConstant *)gain;



@end
