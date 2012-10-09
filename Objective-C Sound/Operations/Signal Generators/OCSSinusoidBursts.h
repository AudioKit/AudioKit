//
//  OCSSinusoidBursts.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOperation.h"

#import "OCSSineTable.h"

/**
 Produces sinusoid bursts useful for formant and granular synthesis.
 */

@interface OCSSinusoidBursts : OCSOperation

@property (nonatomic, strong) OCSSineTable *sineburstSynthesisTable;
@property (nonatomic, strong) OCSFTable *riseShapeTable;
@property (nonatomic, strong) OCSConstant *numberOfOverlaps;
@property (nonatomic, strong) OCSConstant *totalTime;
@property (nonatomic, strong) OCSControl *octavationIndex;
@property (nonatomic, strong) OCSControl *formantBandwidth;
@property (nonatomic, strong) OCSControl *burstRiseTime;
@property (nonatomic, strong) OCSControl *burstDuration;
@property (nonatomic, strong) OCSControl *burstDecayTime;
@property (nonatomic, strong) OCSParameter *peakAmplitude;
@property (nonatomic, strong) OCSParameter *fundamentalFrequency;
@property (nonatomic, strong) OCSParameter *formantFrequency;

-(id) initWithSineTable:(OCSSineTable *)sineburstSynthesisTable
         riseShapeTable:(OCSFTable *)riseShapeTable
               Overlaps:(OCSConstant *)numberOfOverlaps
              totalTime:(OCSConstant *)totalTime
        octavationIndex:(OCSControl *)octavationIndex
       formantBandwidth:(OCSControl *)formantBandwidth
          burstRiseTime:(OCSControl *)burstRiseTime
          burstDuration:(OCSControl *)burstDuration
         burstDecayTime:(OCSControl *)burstDecayTime
          peakAmplitude:(OCSParameter *)peakAmplitude
   fundamentalFrequency:(OCSParameter *)fundamentalFrequency
       formantFrequence:(OCSParameter *)formantFrequency;

@end
