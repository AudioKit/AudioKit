//
//  ViewController.m
//  GlobalEffects
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "ViewController.h"

#import "AKFoundation.h"
#import "AKiOSTools.h"
#import "ToneGenerator.h"
#import "EffectsProcessor.h"

@interface ViewController () {
    ToneGenerator *toneGenerator;
    EffectsProcessor *fx;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AKOrchestra *orch = [[AKOrchestra alloc] init];
    toneGenerator = [[ToneGenerator alloc] init];
    fx = [[EffectsProcessor alloc] initWithAudioSource:toneGenerator.auxilliaryOutput];
    
    [orch addInstrument:toneGenerator];
    [orch addInstrument:fx];
    
    [[AKManager sharedAKManager] runOrchestra:orch];
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
