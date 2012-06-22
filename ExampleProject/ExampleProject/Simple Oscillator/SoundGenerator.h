//
//  SoundGenerator.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCSInstrument.h"
#import "OCSSineTable.h"
#import "OCSOscillator.h"
#import "OCSParamArray.h"
#import "OCSReverb.h"
#import "OCSOutputStereo.h"

@interface SoundGenerator : OCSInstrument {
    OCSProperty *frequency;
}

@property (nonatomic, strong) OCSProperty * frequency;
    
-(id) initWithOrchestra:(OCSOrchestra *)newOrchestra;
-(void) playNoteForDuration:(float)dur Frequency:(float)freq;

@end
