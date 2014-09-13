//
//  GlobalEffectsConductor.m
//  GlobalEffects
//
//  Created by Aurelius Prochazka on 8/4/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "GlobalEffectsConductor.h"

#import "AKFoundation.h"
#import "ToneGenerator.h"
#import "EffectsProcessor.h"

@implementation GlobalEffectsConductor
{
    ToneGenerator *toneGenerator;
    EffectsProcessor *fx;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        AKOrchestra *orch = [[AKOrchestra alloc] init];
        toneGenerator = [[ToneGenerator alloc] init];
        fx = [[EffectsProcessor alloc] initWithAudioSource:toneGenerator.auxilliaryOutput];
        
        [orch addInstrument:toneGenerator];
        [orch addInstrument:fx];
        
        [[AKManager sharedAKManager] runOrchestra:orch];
    }
    return self;
}


- (IBAction)play:(id)sender {
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

