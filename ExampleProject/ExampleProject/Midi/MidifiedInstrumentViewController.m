//
//  MidifiedInstrumentViewController.m
//  Objective-Csound
//
//  Created by Adam Boulanger on 7/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "MidifiedInstrumentViewController.h"
#import "OCSManager.h"
#import "MidifiedInstrument.h"

@interface MidifiedInstrumentViewController ()

@end

@implementation MidifiedInstrumentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];
    MidifiedInstrument *inst = [[MidifiedInstrument alloc] init];
    [orch addInstrument:inst];
    
    [[OCSManager sharedOCSManager] runOrchestra:orch];
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

@end
