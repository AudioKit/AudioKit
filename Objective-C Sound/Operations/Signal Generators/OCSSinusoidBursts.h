//
//  OCSSinusoidBursts.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSParameter+Operation.h"

#import "OCSSineTable.h"

/**
 Produces sinusoid bursts useful for formant and granular synthesis.
 */

@interface OCSSinusoidBursts : OCSParameter

/// Initialize the Sinusoid Bursts
-(id) initWithSineTable:(OCSSineTable *)sineburstSynthesisTable
         riseShapeTable:(OCSFTable *)riseShapeTable
               overlaps:(OCSConstant *)numberOfOverlaps
              totalTime:(OCSConstant *)totalTime
        octavationIndex:(OCSControl *)octavationIndex
       formantBandwidth:(OCSControl *)formantBandwidth
          burstRiseTime:(OCSControl *)burstRiseTime
          burstDuration:(OCSControl *)burstDuration
         burstDecayTime:(OCSControl *)burstDecayTime
          peakAmplitude:(OCSParameter *)peakAmplitude
   fundamentalFrequency:(OCSParameter *)fundamentalFrequency
       formantFrequency:(OCSParameter *)formantFrequency;

@end
