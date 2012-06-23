//
//  MoreGrainViewController.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "MoreGrainViewController.h"

@interface MoreGrainViewController ()

@end

@implementation MoreGrainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    OCSOrchestra *orch = [[OCSOrchestra alloc] init];
    myGrainBirds = [[GrainBirds alloc] init];
    [orch addInstrument:myGrainBirds];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

@end
