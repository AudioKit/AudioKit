//
//  UnitGeneratorsViewController.m
//  AudioKit Example
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UnitGeneratorsViewController.h"
#import "AKManager.h"
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
    AKOrchestra *orch = [[AKOrchestra alloc] init];
    unitGeneratorInstrument = [[UnitGeneratorInstrument alloc] init];
    [orch addInstrument:unitGeneratorInstrument];
    [[AKManager sharedAKManager] runOrchestra:orch];
}

- (IBAction)hit1:(id)sender {
    [unitGeneratorInstrument playForDuration:9.0];
}

- (IBAction)hit2:(id)sender {
    [unitGeneratorInstrument playForDuration:3.0];
}

@end
