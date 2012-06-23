//
//  SoundGenerator.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface SoundGenerator : OCSInstrument {
    OCSProperty *frequency;
}

@property (nonatomic, strong) OCSProperty * frequency;

-(void) playNoteForDuration:(float)dur Frequency:(float)freq;

@end
