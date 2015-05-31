//
//  AKMultitapDelay.h
//  AudioKit
//
//  Auto-generated on 2/19/15.
//  Customized by Aurelius Prochazka adding the addEchoAtTime method
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Multitap delay line implementation.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKMultitapDelay : AKAudio
/// Instantiates the multitap delay
/// @param input Input signal to be delayed.
/// @param firstEchoTime Time in seconds to delay the firsted delayed playback.
/// @param firstEchoGain The relative amplitude of the first echo. [Default Value: ]
- (instancetype)initWithInput:(AKParameter *)input
                firstEchoTime:(AKConstant *)firstEchoTime
                firstEchoGain:(AKConstant *)firstEchoGain;

/// Instantiates the multitap delay
/// @param input Input signal to be delayed.
/// @param firstEchoTime Time in seconds to delay the firsted delayed playback.
/// @param firstEchoGain The relative amplitude of the first echo.
+ (instancetype)delayWithInput:(AKParameter *)input
                 firstEchoTime:(AKConstant *)firstEchoTime
                 firstEchoGain:(AKConstant *)firstEchoGain;

/// Adds an echo or tap to the multi-tap delay line
/// @param time Time in seconds to delay the firsted delayed playback.
/// @param gain The relative amplitude of the first echo.
- (void)addEchoAtTime:(AKConstant *)time gain:(AKConstant *)gain;

@end
NS_ASSUME_NONNULL_END
