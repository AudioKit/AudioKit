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
    OCSEvent *currentEvent;
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
    currentEvent = nil;
}

- (IBAction)playFrequency:(float)frequency { 
    if (currentEvent) [currentEvent stop];
    currentEvent = [[OCSEvent alloc] initWithInstrument:udoInstrument];
    [currentEvent setInstrumentProperty:[udoInstrument frequency] toValue:frequency];
    [currentEvent trigger];
}

- (IBAction)hit1:(id)sender {
    [self playFrequency:440.0f];
}

- (IBAction)hit2:(id)sender { 
    [self playFrequency:[Helper randomFloatFrom:kFrequencyMin to:kFrequencyMax]];
}


@end
