//
//  ReverbViewController.m
//  Objective-Csound Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ReverbViewController.h"
#import "Helper.h"
#import "OCSManager.h"
#import "ToneGenerator.h"
#import "EffectsProcessor.h"

@interface ReverbViewController () {
    EffectsProcessor *fx;
    ToneGenerator *toneGenerator;
}
@end

@implementation ReverbViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];

    toneGenerator = [[ToneGenerator alloc] init];
    fx = [[EffectsProcessor alloc] initWithToneGenerator:toneGenerator];
    
    [orch addInstrument:toneGenerator];
    [orch addInstrument:fx];

    [[OCSManager sharedOCSManager] runOrchestra:orch];

}

- (IBAction)playFrequency:(float)frequency { 
    OCSEvent *currentEvent = [[OCSEvent alloc] initWithInstrument:toneGenerator];
    [currentEvent setProperty:[toneGenerator frequency] toValue:frequency];
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
    [fx start];
}

@end
