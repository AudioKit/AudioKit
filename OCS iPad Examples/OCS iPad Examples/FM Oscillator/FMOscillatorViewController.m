//
//  FMOscillatorViewController.m
//  Objective-C Sound Example
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMOscillatorViewController.h"
#import "Helper.h"
#import "OCSManager.h"

@interface FMOscillatorViewController () {
    FMOscillator *fmOscillator;
    OCSEvent *currentEvent;
}
@end

@implementation FMOscillatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];    
    fmOscillator =  [[FMOscillator alloc] init];
    [orch addInstrument:fmOscillator];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
    currentEvent = nil;
}

- (IBAction)playRandomFrequency:(id)sender
{
    if (currentEvent) {
        OCSEvent *off = [[OCSEvent alloc] initDeactivation:currentEvent afterDuration:0];
        [off trigger];
    }
    float randomFrequency = [Helper randomFloatFrom:kFrequencyMin to:kFrequencyMax];
    currentEvent = [[OCSEvent alloc] initWithInstrument:fmOscillator];
    [currentEvent setEventProperty:[fmOscillator frequency] toValue:randomFrequency];
    [currentEvent trigger];
    
}
- (IBAction)playRandomModulation:(id)sender
{
    float randomModulation = [Helper randomFloatFrom:kModulationMin to:kModulationMax];
    OCSEvent *instrumentChangeEvent = [[OCSEvent alloc] initWithInstrumentProperty:[fmOscillator modulation] value:randomModulation];
    [instrumentChangeEvent trigger];
}

@end
