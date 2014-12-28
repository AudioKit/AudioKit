//
//  AKDelay.h
//  AudioKit
//
//  Auto-generated on 12/26/12.
//  Customized by Aurelius Prochazka on 12/28/13
//
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Simple delay
 
 Delays an input signal by some time interval.
 */

@interface AKDelay : AKAudio

/// Instantiates the delay
/// @param audioSource Audio signal
/// @param delayTime Requested delay time in seconds.
- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKConstant *)delayTime;

- (void)setOptionalFeedback:(AKControl *)feedback;
@end