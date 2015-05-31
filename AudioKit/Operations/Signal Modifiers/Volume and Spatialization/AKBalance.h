//
//  AKBalance.h
//  AudioKit
//
//  Auto-generated on 2/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Adjusts one audio signal according to the values of another.

 This operation outputs a version of the audio source, amplitude-modified so that its rms power is equal to that of the comparator audio source. Thus a signal that has suffered loss of power (eg., in passing through a filter bank) can be restored by matching it with, for instance, its own source. It should be noted that this modifies amplitude only; output signal is not altered in any other respect.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKBalance : AKAudio
/// Instantiates the balance with all values
/// @param input Input audio signal
/// @param comparatorAudioSource The comparator signal
/// @param halfPowerPoint Half-power point (in Hz) of a special internal low-pass filter. The default value is 10. [Default Value: 10]
- (instancetype)initWithInput:(AKParameter *)input
        comparatorAudioSource:(AKParameter *)comparatorAudioSource
               halfPowerPoint:(AKConstant *)halfPowerPoint;

/// Instantiates the balance with default values
/// @param input Input audio signal
/// @param comparatorAudioSource The comparator signal
- (instancetype)initWithInput:(AKParameter *)input
        comparatorAudioSource:(AKParameter *)comparatorAudioSource;

/// Instantiates the balance with default values
/// @param input Input audio signal
/// @param comparatorAudioSource The comparator signal
+ (instancetype)balanceWithInput:(AKParameter *)input
           comparatorAudioSource:(AKParameter *)comparatorAudioSource;

/// Half-power point (in Hz) of a special internal low-pass filter. The default value is 10. [Default Value: 10]
@property (nonatomic) AKConstant *halfPowerPoint;

/// Set an optional half power point
/// @param halfPowerPoint Half-power point (in Hz) of a special internal low-pass filter. The default value is 10. [Default Value: 10]
- (void)setOptionalHalfPowerPoint:(AKConstant *)halfPowerPoint;



@end
NS_ASSUME_NONNULL_END
