//
//  ToneGenerator.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface ToneGenerator : OCSInstrument {
    OCSParam *auxilliaryOutput;
}
@property (nonatomic, strong) OCSProperty *frequency;
@property (readonly) OCSParam *auxilliaryOutput;

- (void)playNoteForDuration:(float)dur Frequency:(float)freq;

@end
