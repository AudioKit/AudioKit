//
//  ExpressionToneGenerator.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface ExpressionToneGenerator : OCSInstrument {
    OCSProperty *frequency;
}

@property (nonatomic, strong) OCSProperty * frequency;

- (void)playNoteForDuration:(float)dur Frequency:(float)freq;

@end
