//
//  GrainViewController.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "GrainViewController.h"
#import "OCSManager.h"
#import "SimpleGrainInstrument.h"

@interface GrainViewController () {
    SimpleGrainInstrument *myGrainInstrument;
}
@end

@implementation GrainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];
    myGrainInstrument = [[SimpleGrainInstrument alloc] init];
    [orch addInstrument:myGrainInstrument];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (IBAction)hit1:(id)sender
{
    [myGrainInstrument playNoteForDuration:15];
}

- (IBAction)hit2:(id)sender
{
    [myGrainInstrument playNoteForDuration:5];
}

@end
