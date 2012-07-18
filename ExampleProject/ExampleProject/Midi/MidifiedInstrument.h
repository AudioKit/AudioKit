//
//  MidifiedInstrument.h
//  Objective-Csound
//
//  Created by Adam Boulanger on 7/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface MidifiedInstrument : OCSInstrument

@property (nonatomic, strong) OCSInstrumentProperty *frequency;
#define kFrequencyMin 110
#define kFrequencyMax 880

@property (nonatomic, strong) OCSInstrumentProperty *modulation;
#define kModulationMin 0.5
#define kModulationMax 2.0

@property  (nonatomic, strong) OCSInstrumentProperty *lowPassCutoffFrequency;
#define kLpCutoffInit 500
#define kLpCutoffMin 200
#define kLpCutoffMax 800

- (void)playNoteForDuration:(float)noteDuration 
                  Frequency:(float)noteFrequency
                 Modulation:(float)noteModulation;

@end
