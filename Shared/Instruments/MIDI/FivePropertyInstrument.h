//
//  FivePropertyInstrument.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 8/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface FivePropertyInstrument : OCSInstrument

@property (nonatomic, strong) OCSEventProperty *volume;
#define kVolumeMin 0.0
#define kVolumeMax 0.8

@property (nonatomic, strong) OCSEventProperty *frequency;
#define kFrequencyMin 20
#define kFrequencyMax 20000

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