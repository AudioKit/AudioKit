//
//  FMGameObject.h
//  Objective-C Sound Example
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Create a new instrument - define opcodes with properties connected to game behavior
//  connect everything to an orchestra which can be managed at gameLevel (manager)
//     orchestra needs visible method to grab text interpretation of this instrument
//

#import "OCSInstrument.h"

@interface FMGameObject : OCSInstrument 

@property (nonatomic, strong) OCSNoteProperty *frequency;
#define kFrequencyMin 110
#define kFrequencyMax 880

@property (nonatomic, strong) OCSInstrumentProperty *modulation;
#define kModulationMin 0.5
#define kModulationMax 2.0

- (void)playNoteForDuration:(float)noteDuration 
                  Frequency:(float)noteFrequency
                 Modulation:(float)noteModulation;

@end
