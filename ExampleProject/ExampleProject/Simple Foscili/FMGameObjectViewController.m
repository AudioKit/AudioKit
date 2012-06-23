//
//  FMOscillatorViewController.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMGameObjectViewController.h"
#import "OCSManager.h"

@implementation FMGameObjectViewController
//ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];    
    myFMGameObject =  [[FMGameObject alloc] init];
    [orch addInstrument:myFMGameObject];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (IBAction)hit1:(id)sender
{
    [myFMGameObject playNoteForDuration:1.0 Frequency:220 Modulation:1.0];
}
- (IBAction)hit2:(id)sender
{
    [myFMGameObject playNoteForDuration:1.0 Frequency:320 Modulation:1.2];
}

@end
