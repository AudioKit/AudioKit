//
//  UDOInstrument.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface UDOInstrument : OCSInstrument {
    OCSProperty *frequency;
}

@property (nonatomic, strong) OCSProperty *frequency;

- (void)playNoteForDuration:(float)dur Frequency:(float)freq;
#define kFrequencyMin 110
#define kFrequencyMax 880

@end
