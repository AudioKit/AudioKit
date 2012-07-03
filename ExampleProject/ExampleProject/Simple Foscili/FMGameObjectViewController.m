//
//  FMOscillatorViewController.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMGameObjectViewController.h"
#import "Helper.h"
#import "OCSManager.h"

@interface FMGameObjectViewController () {
    FMGameObject *myFMGameObject;
}
@end

@implementation FMGameObjectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];    
    myFMGameObject =  [[FMGameObject alloc] init];
    [orch addInstrument:myFMGameObject];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (IBAction)playRandomFrequency:(id)sender
{
    float randomFrequency = [Helper randomFloatFrom:kFrequencyMin to:kFrequencyMax];
    [[myFMGameObject frequency] setValue:randomFrequency];
    [myFMGameObject playNoteForDuration:1.0];
}
- (IBAction)playRandomModulation:(id)sender
{
    float randomModulation = [Helper randomFloatFrom:kModulationMin to:kModulationMax];
    [[myFMGameObject modulation] setValue:randomModulation];
    [myFMGameObject playNoteForDuration:1.0];
}

@end
