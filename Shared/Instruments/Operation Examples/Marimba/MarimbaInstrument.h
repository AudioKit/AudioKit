//
//  MarimbaInstrument.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 10/29/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFoundation.h"

@interface MarimbaInstrument : OCSInstrument

@end


@interface MarimbaNote : OCSNote

@property (nonatomic, strong) OCSNoteProperty *frequency;
#define kFrequencyInit 440
#define kFrequencyMin  110
#define kFrequencyMax  880

@property (nonatomic, strong) OCSNoteProperty *amplitude;
#define kAmplitudeInit 0.2
#define kAmplitudeMin  0
#define kAmplitudeMax  1

@property (nonatomic, strong) OCSNoteProperty *vibratoFrequency;
#define kVibratoFrequencyInit 0
#define kVibratoFrequencyMin  0
#define kVibratoFrequencyMax  12

@property (nonatomic, strong) OCSNoteProperty *vibratoAmplitude;
#define kVibratoAmplitudeInit 0
#define kVibratoAmplitudeMin  0
#define kVibratoAmplitudeMax  10

@end