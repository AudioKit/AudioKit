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
}

- (IBAction)hit1:(id)sender {
    toneGenerator.frequency.value = 440.0f;
    [toneGenerator playForDuration:0.1];
}

- (IBAction)hit2:(id)sender {
    [toneGenerator.frequency randomize];
    [toneGenerator playForDuration:0.1];
}

- (IBAction)startFX:(id)sender {
    [fx play];
}

- (IBAction)stopFX:(id)sender {
    [fx stop];
}

@end
