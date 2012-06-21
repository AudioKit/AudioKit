//
//  SoundGenerator.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSDInstrument.h"
#import "CSDSineTable.h"
#import "CSDOscillator.h"
#import "CSDParamArray.h"
#import "CSDReverb.h"
#import "CSDOutputStereo.h"

@interface SoundGenerator : CSDInstrument {
    CSDProperty *frequency;
}

@property (nonatomic, strong) CSDProperty * frequency;
    
-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void) playNoteForDuration:(float)dur Frequency:(float)freq;

@end
