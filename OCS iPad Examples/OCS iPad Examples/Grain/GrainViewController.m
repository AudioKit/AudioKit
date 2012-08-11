//
//  GrainViewController.m
//  Objective-C Sound Example
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "GrainViewController.h"
#import "OCSManager.h"
#import "SimpleGrainInstrument.h"

@interface GrainViewController () {
    SimpleGrainInstrument *grainInstrument;
}
@end

@implementation GrainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];
    grainInstrument = [[SimpleGrainInstrument alloc] init];
    [orch addInstrument:grainInstrument];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (IBAction)hit1:(id)sender
{
    [grainInstrument playNoteForDuration:15];
}

- (IBAction)hit2:(id)sender
{
    [grainInstrument playNoteForDuration:5];
}

@end
