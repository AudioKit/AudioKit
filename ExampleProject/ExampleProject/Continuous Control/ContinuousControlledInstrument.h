//
//  ContinuousControlledInstrument.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDManager.h"
#import "CSDInstrument.h"

#import "CSDSineTable.h"
#import "CSDFoscili.h"

#import "CSDOutputStereo.h"

@interface ContinuousControlledInstrument : CSDInstrument
{
    //CSDContinuousManager *myContinuousManager;
    
    //maintain reference to continuous params so they can be referenced from controlling game logic 
    CSDContinuous *amplitude;
    CSDContinuous *modulation;
    CSDContinuous *modIndex;
}
//@property (nonatomic, strong) CSDContinuousManager * myContinuousManager;
@property (nonatomic, strong) CSDContinuous * amplitude;
@property (nonatomic, strong) CSDContinuous * modulation;
@property (nonatomic, strong) CSDContinuous * modIndex;

-(id)initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void) playNoteForDuration:(float)dur Frequency:(float)freq;

@end
