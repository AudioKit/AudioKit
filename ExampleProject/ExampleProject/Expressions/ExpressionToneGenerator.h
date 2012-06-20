//
//  ExpressionToneGenerator.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDInstrument.h"
#import "CSDSineTable.h"
#import "CSDOscillator.h"
#import "CSDLine.h"
#import "CSDOutputStereo.h"

@interface ExpressionToneGenerator : CSDInstrument

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void) playNoteForDuration:(float)dur Frequency:(float)freq;


@end
