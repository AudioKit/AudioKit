//
//  FivePropertyInstrument.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 8/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFoundation.h"

@class FivePropertyInstrumentNote;

@interface FivePropertyInstrument : OCSInstrument

@property (nonatomic, strong) OCSInstrumentProperty *pitchBend;
#define kPitchBendMin 0.5
#define kPitchBendMax 2.0

@property (nonatomic, strong) OCSInstrumentProperty *modulation;
#define kModulationMin 1.0
#define kModulationMax 2.0

@property  (nonatomic, strong) OCSInstrumentProperty *cutoffFrequency;
#define kLpCutoffMin  200
#define kLpCutoffMax  800

@end

@interface FivePropertyInstrumentNote : OCSNote

#define kVolumeInit 0.2
#define kVolumeMin  0.0
#define kVolumeMax  0.8
@property (nonatomic, strong) OCSNoteProperty *volume;

#define kFrequencyMin 20
#define kFrequencyMax 20000
@property (nonatomic, strong) OCSNoteProperty *frequency;

- (instancetype)initWithFrequency:(float)frequency atVolume:(float)volume;

@end