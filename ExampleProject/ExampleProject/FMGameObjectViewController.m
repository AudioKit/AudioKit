//
//  FMOscillatorViewController.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "FMGameObjectViewController.h"

@interface FMGameObjectViewController ()

@end

@implementation FMGameObjectViewController
//ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    CSDOrchestra * orch = [[CSDOrchestra alloc] init];    
    
    myFMGameObject =  [[FMGameObject alloc] initWithOrchestra:orch];
    
    [[CSDManager sharedCSDManager] runOrchestra:orch];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)hit1:(id)sender
{
    [myFMGameObject playNoteForDuration:1.0 Pitch:440 Modulation:1.0];
}
- (IBAction)hit2:(id)sender
{
    [myFMGameObject playNoteForDuration:1.0 Pitch:660 Modulation:1.2];
}

@end
