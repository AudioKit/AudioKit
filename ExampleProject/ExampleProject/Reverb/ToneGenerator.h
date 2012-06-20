//
//  ToneGenerator.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDInstrument.h"
#import "CSDSineTable.h"
#import "CSDOscillator.h"
#import "CSDOutputStereo.h"

@interface ToneGenerator : CSDInstrument {
    CSDParam * auxilliaryOutput;
}
@property (readonly) CSDParam * auxilliaryOutput;

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void) playNoteForDuration:(float)dur Frequency:(float)freq;

@end
