//
//  FMOscillatorViewController.m
//  Objective-C Sound Example
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMGameObjectViewController.h"
#import "Helper.h"
#import "OCSManager.h"

@interface FMGameObjectViewController () {
    FMGameObject *fmGameObject;
    OCSEvent *currentEvent;
}
@end

@implementation FMGameObjectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];    
    fmGameObject =  [[FMGameObject alloc] init];
    [orch addInstrument:fmGameObject];
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
    currentEvent = [[OCSEvent alloc] initWithInstrument:fmGameObject];
    [currentEvent setNoteProperty:[fmGameObject frequency] toValue:randomFrequency];
    [currentEvent trigger];
    
}
- (IBAction)playRandomModulation:(id)sender
{
    float randomModulation = [Helper randomFloatFrom:kModulationMin to:kModulationMax];
    OCSEvent *instrumentChangeEvent = [[OCSEvent alloc] initWithInstrumentProperty:[fmGameObject modulation] value:randomModulation];
    [instrumentChangeEvent trigger];
}

@end
