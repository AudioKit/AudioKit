//
//  TweakableInstrument.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "OCSSineTable.h"
#import "OCSFoscili.h"
#import "OCSOutputStereo.h"

@interface TweakableInstrument : OCSInstrument
{
    //OCSPropertyManager *myPropertyManager;
    
    //maintain reference to properties so they can be referenced from controlling game logic 
    OCSProperty *amplitude;
    OCSProperty *frequency;
    OCSProperty *modulation;
    OCSProperty *modIndex;
}
//@property (nonatomic, strong) OCSPropertyManager * myPropertyManager;
@property (nonatomic, strong) OCSProperty * amplitude;
@property (nonatomic, strong) OCSProperty * frequency;
@property (nonatomic, strong) OCSProperty * modulation;
@property (nonatomic, strong) OCSProperty * modIndex;

-(void) playNoteForDuration:(float)dur Frequency:(float)freq;

@end
