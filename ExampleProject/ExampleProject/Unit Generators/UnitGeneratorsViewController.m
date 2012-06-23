//
//  UnitGeneratorsViewController.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UnitGeneratorsViewController.h"
#import "OCSManager.h"

@implementation UnitGeneratorsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    OCSOrchestra * orch = [[OCSOrchestra alloc] init];
    myUnitGenSoundGenerator = [[UnitGenSoundGenerator alloc] init];
    [orch addInstrument:myUnitGenSoundGenerator];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

-(IBAction)hit1:(id)sender
{
    [myUnitGenSoundGenerator playNoteForDuration:9.0];
}

-(IBAction)hit2:(id)sender
{
    [myUnitGenSoundGenerator playNoteForDuration:3.0];
}

@end
