//
//  ReverbViewController.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ReverbViewController.h"
#import "Helper.h"
#import "ToneGenerator.h"
#import "EffectsProcessor.h"

@interface ReverbViewController () {
    ToneGenerator *toneGenerator;
    EffectsProcessor *fx;
}
@end

@implementation ReverbViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];
    toneGenerator = [[ToneGenerator alloc] init];
    fx = [[EffectsProcessor alloc] initWithToneGenerator:toneGenerator];
    
    [orch addInstrument:toneGenerator];
    [orch addInstrument:fx];
    
    [[OCSManager sharedOCSManager] runOrchestra:orch];
    
    [toneGenerator start];
}

- (IBAction)playFrequency:(float)frequency {
    
    toneGenerator.frequency.value = frequency;
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
