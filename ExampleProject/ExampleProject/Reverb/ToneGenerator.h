//
//  ToneGenerator.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDInstrument.h"
#import "CSDOscillator.h"
#import "CSDSineTable.h"
#import "CSDOutputStereo.h"
#import "EffectsProcessor.h"
#import "CSDParam.h"
#import "CSDAssignment.h"

@interface ToneGenerator : CSDInstrument {
    EffectsProcessor * fx;
}

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra 
       EffectsProcessor:(EffectsProcessor *) effects;
-(void) playNoteForDuration:(float)dur Pitch:(float)pitch;

@end
