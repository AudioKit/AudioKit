//
//  ToneGenerator.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface ToneGenerator : OCSInstrument {
    OCSParameter *auxilliaryOutput;
}
@property (nonatomic, strong) OCSProperty *frequency;
#define kFrequencyMin 110
#define kFrequencyMax 880

@property (readonly) OCSParameter *auxilliaryOutput;

- (void)playNoteForDuration:(float)dur Frequency:(float)freq;

@end
