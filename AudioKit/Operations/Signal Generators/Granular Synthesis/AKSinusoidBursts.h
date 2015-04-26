//
//  AKSinusoidBursts.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/9/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Produces sinusoid bursts useful for formant and granular synthesis.
 */

NS_ASSUME_NONNULL_BEGIN
@interface AKSinusoidBursts : AKAudio

/// Initialize the Sinusoid Bursts
/// @param sineburstSynthesisTable Sine table for sineburst synthesis (size of at least 4096 recommended)
/// @param riseShapeTable          Used forwards and backwards to shape the sineburst rise and decay; this may be linear or perhaps a sigmoid
/// @param numberOfOverlaps        Number of preallocated spaces needed to hold overlapping burst data. Overlaps are frequency dependent, and the space required depends on the maximum value of fundamentalFrequency and burstDuration. Can be over-estimated at no computation cost.
/// @param totalTime               Total time during which the bursts will be active. Normally set to note duration. No new sineburst is created if it cannot complete its kdur within the remaining totalTime.
/// @param octavationIndex         Normally zero. If greater than zero, lowers the effective fundamental frequency by attenuating odd-numbered sinebursts. Whole numbers are full octaves, fractions transitional.
/// @param formantBandwidth        Formant bandwidth (at -6dB), expressed in Hz. The bandwidth determines the rate of exponential decay throughout the sineburst, before the enveloping described below is applied.
/// @param burstRiseTime           Rise time in seconds.  Typical value for vocal imitation is 0.003.
/// @param burstDuration           Overall duration in seconds.  Typical value for vocal imitation is 0.02.
/// @param burstDecayTime          Decay time in seconds. Typical value for vocal imitation is 0.007.
/// @param peakAmplitude           Peak amplitude of each sineburst, observed at the true end of its rise pattern. The rise may exceed this value given a large bandwidth (say, Q < 10) and/or when the bursts are overlapping.
/// @param fundamentalFrequency    Fundamental frequency (in Hertz) of the impulses that create new sinebursts.
/// @param formantFrequency        Freq of the sinusoid burst induced by each fundamental frequency impulse. This frequency can be fixed for each burst or can vary continuously.
- (instancetype)initWithSineTable:(AKTable *)sineburstSynthesisTable
                   riseShapeTable:(AKTable *)riseShapeTable
                         overlaps:(AKConstant *)numberOfOverlaps
                        totalTime:(AKConstant *)totalTime
                  octavationIndex:(AKControl *)octavationIndex
                 formantBandwidth:(AKControl *)formantBandwidth
                    burstRiseTime:(AKControl *)burstRiseTime
                    burstDuration:(AKControl *)burstDuration
                   burstDecayTime:(AKControl *)burstDecayTime
                    peakAmplitude:(AKParameter *)peakAmplitude
             fundamentalFrequency:(AKParameter *)fundamentalFrequency
                 formantFrequency:(AKParameter *)formantFrequency;

@end
NS_ASSUME_NONNULL_END
