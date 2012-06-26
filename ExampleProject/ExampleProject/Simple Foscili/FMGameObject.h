//
//  FMGameObject.h
//  ExampleProject
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

- (void)playNoteForDuration:(float)dur 
                  Frequency:(float)freq 
                 Modulation:(float)mod;

@end
