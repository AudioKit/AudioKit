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

    OCSOrchestra *o = [[OCSOrchestra alloc] init];
    myGrainBirds = [[GrainBirds alloc] initWithOrchestra:o];
    [[OCSManager sharedOCSManager] runOrchestra:o];
}

@end
