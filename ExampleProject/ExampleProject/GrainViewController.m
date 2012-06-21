//
//  GrainViewController.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "GrainViewController.h"

@interface GrainViewController ()

@end

@implementation GrainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CSDOrchestra *orch = [[CSDOrchestra alloc] init];
    myGrainInstrument = [[SimpleGrainInstrument alloc] initWithOrchestra:orch];
    [[CSDManager sharedCSDManager] runOrchestra:orch];
}

-(IBAction)hit1:(id)sender
{}

-(IBAction)hit2:(id)sender
{}

@end
