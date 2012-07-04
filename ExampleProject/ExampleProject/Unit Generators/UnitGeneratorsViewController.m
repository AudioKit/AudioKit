//
//  UnitGeneratorsViewController.m
//  Objective-Csound Example
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UnitGeneratorsViewController.h"
#import "OCSManager.h"
#import "UnitGeneratorInstrument.h"

@interface UnitGeneratorsViewController () {
    UnitGeneratorInstrument *unitGeneratorInstrument;
}
@end

@implementation UnitGeneratorsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];
    unitGeneratorInstrument = [[UnitGeneratorInstrument alloc] init];
    [orch addInstrument:unitGeneratorInstrument];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (IBAction)hit1:(id)sender
{
    [unitGeneratorInstrument playNoteForDuration:9.0];
}

- (IBAction)hit2:(id)sender
{
    [unitGeneratorInstrument playNoteForDuration:3.0];
}

@end
