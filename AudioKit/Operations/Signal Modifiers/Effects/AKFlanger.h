//
//  AKFlanger.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Flange effect

 This is useful for generating choruses and flangers. The delay must be varied at audio-rate connecting delay to an oscillator output.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKFlanger : AKAudio
/// Instantiates the flanger with all values
/// @param input Input signal.
/// @param delayTime Delay in seconds [Default Value: ]
/// @param feedback Feedback amount (in normal tasks this should not exceed 1, even if bigger values are allowed) Updated at Control-rate. [Default Value: 0]
- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKParameter *)delayTime
                     feedback:(AKParameter *)feedback;

/// Instantiates the flanger with default values
/// @param input Input signal.
/// @param delayTime Delay in seconds
- (instancetype)initWithInput:(AKParameter *)input
                    delayTime:(AKParameter *)delayTime;

/// Instantiates the flanger with default values
/// @param input Input signal.
/// @param delayTime Delay in seconds
+ (instancetype)effectWithInput:(AKParameter *)input
                      delayTime:(AKParameter *)delayTime;

/// Feedback amount (in normal tasks this should not exceed 1, even if bigger values are allowed) [Default Value: 0]
@property (nonatomic) AKParameter *feedback;

/// Set an optional feedback
/// @param feedback Feedback amount (in normal tasks this should not exceed 1, even if bigger values are allowed) Updated at Control-rate. [Default Value: 0]
- (void)setOptionalFeedback:(AKParameter *)feedback;



@end
NS_ASSUME_NONNULL_END
