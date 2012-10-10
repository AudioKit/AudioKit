//
//  OCSAdditiveCosines.m
//  Explorable Explanations
//
//  Created by Adam Boulanger on 10/8/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSAdditiveCosines.h"

@interface OCSAdditiveCosines ()
{
    OCSConstant *pts;
    OCSConstant *phs;
    OCSControl *numHarmonics;
    OCSControl *firstHarmonic;
    OCSControl *partialMul;
    OCSParameter *freq;
    OCSParameter *amp;
    OCSParameter *output;
    
    OCSFTable *f;
}
@end

@implementation OCSAdditiveCosines

/*
-(id)initWithNumberOfCosineTablePoints:(OCSConstant *)numberOfCosineTablePoints 
        harmonicsCount:(OCSControl *)harmonicsCount
      firstHarmonicIdx:(OCSControl *)firstHarmonicIdx 
     partialMultiplier:(OCSControl *)partialMultiplier 
  fundamentalFrequency:(OCSParameter *)fundamentalFrequency 
             amplitude:(OCSParameter *)amplitude
{
    self = [super init];
    if (self) {
        pts = numberOfCosineTablePoints;
        phs = ocspi(0);
        numHarmonics = harmonicsCount;
        firstHarmonic = firstHarmonicIdx;
        partialMul = partialMultiplier;
        freq = fundamentalFrequency;
        amp = amplitude;
        
    }
    return self;
}

-(id)initWithNumberOfCosineTablePoints:(OCSConstant *)numberOfCosineTablePoints 
               phase:(OCSConstant *)phase
      harmonicsCount:(OCSControl *)harmonicsCount 
    firstHarmonicIdx:(OCSControl *)firstHarmonicIdx 
   partialMultiplier:(OCSControl *)partialMultiplier 
fundamentalFrequency:(OCSParameter *)fundamentalFrequency 
           amplitude:(OCSParameter *)amplitude
{
    self = [super init];
    if (self) {
        pts = numberOfCosineTablePoints;
        phs = phase;
        numHarmonics = harmonicsCount;
        firstHarmonic = firstHarmonicIdx;
        partialMul = partialMultiplier;
        freq = fundamentalFrequency;
        amp = amplitude;
        
    }
    return self;
}



- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@ gbuzz %@, %@, %@, %@, %@, %@, %@",
            output, amp, freq, numHarmonics, firstHarmonic, partialMul, ... ];
}
 */

-(id)initWithFTable:(OCSFTable *)cosineTable
     harmonicsCount:(OCSControl *)harmonicsCount
   firstHarmonicIdx:(OCSControl *)firstHarmonicIdx
  partialMultiplier:(OCSControl *)partialMultiplier
fundamentalFrequency:(OCSParameter *)fundamentalFrequency
          amplitude:(OCSParameter *)amplitude
{
    self = [super init];
    if (self) {
        f = cosineTable;
        phs = ocspi(0);
        numHarmonics = harmonicsCount;
        firstHarmonic = firstHarmonicIdx;
        partialMul = partialMultiplier;
        freq = fundamentalFrequency;
        amp = amplitude;
    }
    return self;
}

- (NSString *)stringForCSD
{
    if (output == nil) output = [OCSParameter parameterWithString:[self operationName]];
    
    return [NSString stringWithFormat:
            @"%@ gbuzz %@, %@, %@, %@, %@, %@, %@",
            output, amp, freq, numHarmonics, firstHarmonic, partialMul, f, phs];
}

- (NSString *)description {
    return [output parameterString];
}

@end
