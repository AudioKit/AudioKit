//
//  MarimbaInstrument.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/29/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFoundation.h"

@interface MarimbaInstrument : AKInstrument

@end


@interface MarimbaNote : AKNote

@property (nonatomic, strong) AKNoteProperty *frequency;
#define kFrequencyInit 440
#define kFrequencyMin  110
#define kFrequencyMax  880

@property (nonatomic, strong) AKNoteProperty *amplitude;
#define kAmplitudeInit 0.2
#define kAmplitudeMin  0
#define kAmplitudeMax  1

@property (nonatomic, strong) AKNoteProperty *vibratoFrequency;
#define kVibratoFrequencyInit 0
#define kVibratoFrequencyMin  0
#define kVibratoFrequencyMax  12

@property (nonatomic, strong) AKNoteProperty *vibratoAmplitude;
#define kVibratoAmplitudeInit 0
#define kVibratoAmplitudeMin  0
#define kVibratoAmplitudeMax  10

@end