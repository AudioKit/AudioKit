//
//  UDOViewController.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOViewController.h"
#import "Helper.h"
#import "OCSManager.h"

@interface UDOViewController () {
    UDOInstrument *udoInstrument;
}
@end

@implementation UDOViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    OCSOrchestra *orch = [[OCSOrchestra alloc] init];    
    udoInstrument =  [[UDOInstrument alloc] init];
    [orch addInstrument:udoInstrument];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (IBAction)playFrequency:(float)frequency
{
    [udoInstrument playNoteForDuration:1.0];    
    udoInstrument.frequency.value = frequency;
}

- (IBAction)hit1:(id)sender {
    [self playFrequency:440.0f];
}

- (IBAction)hit2:(id)sender { 
    [self playFrequency:[Helper randomFloatFrom:kFrequencyMin to:kFrequencyMax]];
}


@end
