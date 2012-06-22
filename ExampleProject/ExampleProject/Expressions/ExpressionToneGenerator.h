//
//  ExpressionToneGenerator.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/10/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "OCSSineTable.h"
#import "OCSOscillator.h"
#import "OCSLine.h"
#import "OCSOutputStereo.h"

@interface ExpressionToneGenerator : OCSInstrument {
    OCSProperty *frequency;
}

@property (nonatomic, strong) OCSProperty * frequency;

-(id) initWithOrchestra:(OCSOrchestra *)newOrchestra;
-(void) playNoteForDuration:(float)dur Frequency:(float)freq;


@end
