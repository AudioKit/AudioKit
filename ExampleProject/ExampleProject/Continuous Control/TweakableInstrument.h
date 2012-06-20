//
//  TweakableInstrument.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDInstrument.h"
#import "CSDSineTable.h"
#import "CSDFoscili.h"
#import "CSDOutputStereo.h"

@interface TweakableInstrument : CSDInstrument
{
    //CSDPropertyManager *myPropertyManager;
    
    //maintain reference to properties so they can be referenced from controlling game logic 
    CSDProperty *amplitude;
    CSDProperty *frequency;
    CSDProperty *modulation;
    CSDProperty *modIndex;
}
//@property (nonatomic, strong) CSDPropertyManager * myPropertyManager;
@property (nonatomic, strong) CSDProperty * amplitude;
@property (nonatomic, strong) CSDProperty * frequency;
@property (nonatomic, strong) CSDProperty * modulation;
@property (nonatomic, strong) CSDProperty * modIndex;

-(id)initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void) playNoteForDuration:(float)dur Frequency:(float)freq;

@end
