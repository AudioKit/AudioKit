//
//  GrainViewController.m
//  AudioKit Example
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "GrainViewController.h"
#import "AKManager.h"
#import "SimpleGrainInstrument.h"

@interface GrainViewController () {
    SimpleGrainInstrument *grainInstrument;
}
@end

@implementation GrainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AKOrchestra *orch = [[AKOrchestra alloc] init];
    grainInstrument = [[SimpleGrainInstrument alloc] init];
    [orch addInstrument:grainInstrument];
    [[AKManager sharedAKManager] runOrchestra:orch];
}

- (IBAction)hit1:(id)sender
{
    [grainInstrument playForDuration:15];
}

- (IBAction)hit2:(id)sender
{
    [grainInstrument playForDuration:5];
}

@end
