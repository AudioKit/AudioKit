//
//  OscillatorInstrument.h
//  OCSiPad
//
//  Created by Aurelius Prochazka on 8/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface OscillatorInstrument : OCSInstrument

@property (nonatomic, strong) OCSInstrumentProperty *frequency;
#define kFrequencyInit 440
#define kFrequencyMin  110
#define kFrequencyMax  880

@property (nonatomic, strong) OCSInstrumentProperty *amplitude;
#define kAmplitudeInit 0.2
#define kAmplitudeMin  0
#define kAmplitudeMax  1

@end
