//
//  AKScaledFSignal.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKParameter+Operation.h"
#import "AKFSignal.h"

/** Scale the frequency components of a pv stream, resulting in pitch shift.
 Output amplitudes can be optionally modified in order to attempt formant preservation.
 
 The quality of the pitch shift will be improved with the use of a Hanning window in the pvoc analysis.
 Liftered Cepstrum Formant preservation method is less intensive than the true envelope method,
 which might not be suited to realtime use.
 */

typedef enum
{
    kFormantRetainMethodNone=0,
    kFormantRetainMethodLifteredCepstrum=1,
    kFormantRetainMethodTrueEnvelope=2,
} FormantRetainMethodType;

@interface AKScaledFSignal : AKFSignal

/// Create a frequency-scaled phase vocoder stream from another stream
/// @param input          Source f-signal
/// @param frequencyRatio Scaling ratio.
- (instancetype)initWithInput:(AKFSignal *)input
               frequencyRatio:(AKControl *)frequencyRatio;

/// Create a frequency-scaled phase vocoder stream from another stream
/// @param input                        Source f-signal.
/// @param frequencyRatio               Scaling ratio.
/// @param formantRetainMethod          Method by which to attempt to keep input signal formants.
/// @param amplitudeRatio               Amplitude scaling ratio (default 1.0 equals no change)
/// @param numberOfCepstrumCoefficients Number of coefficients to use in formant preservation (defaults ot 80).
- (instancetype)initWithInput:(AKFSignal *)input
               frequencyRatio:(AKControl *)frequencyRatio
          formantRetainMethod:(FormantRetainMethodType) formantRetainMethod
               amplitudeRatio:(AKControl *)amplitudeRatio
         cepstrumCoefficients:(AKControl *)numberOfCepstrumCoefficients;


@end
