//
//  ReverbViewController.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ReverbViewController.h"
#import "Helper.h"
#import "ReverbOrchestra.h"

@interface ReverbViewController () {
    ReverbOrchestra *orch;
}
@end

@implementation ReverbViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    orch = [[ReverbOrchestra alloc] init];
}

- (IBAction)playFrequency:(float)frequency { 
    OCSEvent *currentEvent = [[OCSEvent alloc] initWithInstrument:orch.toneGenerator];
    [currentEvent setInstrumentProperty:[orch.toneGenerator frequency] toValue:frequency];
    [currentEvent trigger];
    OCSEvent *off = [[OCSEvent alloc] initDeactivation:currentEvent afterDuration:0.5];
    [off trigger];
}

- (IBAction)hit1:(id)sender {
    [self playFrequency:440.0f];
}

- (IBAction)hit2:(id)sender { 
    [self playFrequency:[Helper randomFloatFrom:kFrequencyMin to:kFrequencyMax]];
}

- (IBAction)startFX:(id)sender {
    [orch.fx start];
}

@end
