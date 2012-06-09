//
//  UnitGenSoundGenerator.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDManager.h"
#import "CSDConstants.h"
#import "CSDInstrument.h"

#import "CSDOscillator.h"
#import "CSDFoscili.h"

#import "CSDLine.h"
#import "CSDLineSegment.h"

@interface UnitGenSoundGenerator : CSDInstrument
{
    CSDFoscili *myFMOscillator;
    CSDLine *myLine;
    CSDLineSegment *myLineSegment_a;
    CSDLineSegment *myLineSegment_b;
}

-(id)initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void)playNoteForDuration:(float)dur;

@end
