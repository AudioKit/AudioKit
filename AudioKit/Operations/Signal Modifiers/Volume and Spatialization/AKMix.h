//
//  AKMix.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/28/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"
#import "AKStereoAudio.h"

/** Calculates the weighted mean value of two input signals.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKMix : AKAudio

/// Create a weighted mean of two inputs using a balance point.
/// @param input1 First input
/// @param input2 Second input
/// @param balancePoint A number from 0 (all input 1) to 1 (all input 2).
- (instancetype)initWithInput1:(AKParameter *)input1
                        input2:(AKParameter *)input2
                        balance:(AKParameter *)balancePoint;

/// Create a mono audio from equal parts of the left and right channels of a stereo input
/// @param stereoInput Stereo audio source to be mixed down to mono
- (instancetype)initMonoAudioFromStereoInput:(AKStereoAudio *)stereoInput;

/// Set the minimum balance point.
/// @param minimumBalancePoint The value for which the balance point would indicate all input 1.
- (void)setMinimumBalancePoint:(AKConstant *)minimumBalancePoint;

/// Set the maximum balance point.
/// @param maximumBalancePoint The value for which the balance point would indicate all input 2.
- (void)setMaximumBalancePoint:(AKConstant *)maximumBalancePoint;

@end
NS_ASSUME_NONNULL_END
