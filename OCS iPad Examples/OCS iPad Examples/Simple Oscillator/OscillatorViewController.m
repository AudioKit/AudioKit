//
//  OscillatorViewController.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OscillatorViewController.h"
#import "Helper.h"
#import "OCSManager.h"
#import "SimpleOscillator.h"

@interface OscillatorViewController () {
    SimpleOscillator *simpleOscillator;
    OCSEvent *currentEvent;
}
@end
@implementation OscillatorViewController
@synthesize frequencyLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];    
    simpleOscillator =  [[SimpleOscillator alloc] init];
    [orch addInstrument:simpleOscillator];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
    currentEvent = nil;
}

- (IBAction)playFrequency:(float)frequency { 
    if (currentEvent) {
        OCSEvent *off = [[OCSEvent alloc] initDeactivation:currentEvent afterDuration:0];
        [off trigger];
    }
    [frequencyLabel setText:[NSString stringWithFormat:@"%g", frequency]];
    currentEvent = [[OCSEvent alloc] initWithInstrument:simpleOscillator];
    [currentEvent setNoteProperty:[simpleOscillator frequency] toValue:frequency];
    [currentEvent trigger];
}

- (IBAction)playA:(id)sender {
    [self playFrequency:440.0f];
}

- (IBAction)playRandomFrequency:(id)sender { 
    [self playFrequency:[Helper randomFloatFrom:kFrequencyMin to:kFrequencyMax]];
}

- (void)viewDidUnload {
    [self setFrequencyLabel:nil];
    [super viewDidUnload];
}
@end
