//
//  MoreGrainViewController.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "MoreGrainViewController.h"
#import "OCSManager.h"
#import "OCSOrchestra.h"

@implementation MoreGrainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    OCSOrchestra *orch = [[OCSOrchestra alloc] init];
    myGrainBirds = [[GrainBirds alloc] init];
    NSLog(@"get here.");
    fx = [[GrainBirdsReverb alloc] initWithGrainBirds:myGrainBirds];
    NSLog(@"get here a.");    
    [orch addInstrument:myGrainBirds];
    [orch addInstrument:fx];
    
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

@end
