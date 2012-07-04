//
//  UDOViewController.m
//  Objective-Csound Example
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOViewController.h"
#import "Helper.h"
#import "OCSManager.h"

@interface UDOViewController () {
    UDOInstrument * udoInstrument;
}
@end

@implementation UDOViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];    
    udoInstrument =  [[UDOInstrument alloc] init];
    [orch addInstrument:udoInstrument];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (IBAction)hit1:(id)sender {
    [udoInstrument playNoteForDuration:0.5 Frequency:440];
}

- (IBAction)hit2:(id)sender {
    float randomFrequency = [Helper randomFloatFrom:kFrequencyMin to:kFrequencyMax];
    [udoInstrument playNoteForDuration:0.5 Frequency:randomFrequency];
}

@end
