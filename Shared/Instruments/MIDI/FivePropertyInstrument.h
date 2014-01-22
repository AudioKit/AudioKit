//
//  FivePropertyInstrument.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFoundation.h"

@class FivePropertyInstrumentNote;

@interface FivePropertyInstrument : AKInstrument

@property (nonatomic, strong) AKInstrumentProperty *pitchBend;
#define kPitchBendMin 0.5
#define kPitchBendMax 2.0

@property (nonatomic, strong) AKInstrumentProperty *modulation;
#define kModulationMin 1.0
#define kModulationMax 2.0

@property  (nonatomic, strong) AKInstrumentProperty *cutoffFrequency;
#define kLpCutoffMin  200
#define kLpCutoffMax  800

@end

@interface FivePropertyInstrumentNote : AKNote

#define kVolumeInit 0.2
#define kVolumeMin  0.0
#define kVolumeMax  0.8
@property (nonatomic, strong) AKNoteProperty *volume;

#define kFrequencyMin 20
#define kFrequencyMax 20000
@property (nonatomic, strong) AKNoteProperty *frequency;

- (instancetype)initWithFrequency:(float)frequency atVolume:(float)volume;

@end