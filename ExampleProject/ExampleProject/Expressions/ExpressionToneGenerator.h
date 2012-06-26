//
//  ExpressionToneGenerator.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface ExpressionToneGenerator : OCSInstrument

- (void)playNoteForDuration:(float)dur Frequency:(float)freq;

@end
