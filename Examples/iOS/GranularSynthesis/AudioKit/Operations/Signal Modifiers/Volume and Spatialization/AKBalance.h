//
//  AKBalance.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/24/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Adjusts one audio signal according to the values of another.
 
 This operation outputs a version of the audio source, amplitude-modified so that its rms power is equal to that of the comparator audio source. Thus a signal that has suffered loss of power (eg., in passing through a filter bank) can be restored by matching it with, for instance, its own source. It should be noted that this modifies amplitude only; output signal is not altered in any other respect.
 */

@interface AKBalance : AKAudio

/// Instantiates the balance
/// @param audioSource Input audio signal
/// @param comparatorAudioSource The comparator signal
- (instancetype)initWithAudioSource:(AKAudio *)audioSource
              comparatorAudioSource:(AKAudio *)comparatorAudioSource;


/// Set an optional half power point
/// @param halfPowerPoint Half-power point (in Hz) of a special internal low-pass filter. The default value is 10.
- (void)setOptionalHalfPowerPoint:(AKConstant *)halfPowerPoint;


@end