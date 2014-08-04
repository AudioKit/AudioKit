//
//  AppDelegate.m
//  GlobalEffects
//
//  Created by Aurelius Prochazka on 8/4/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AppDelegate.h"
#import "AKFoundation.h"
#import "ToneGenerator.h"
#import "EffectsProcessor.h"

@interface AppDelegate () {
    ToneGenerator *toneGenerator;
    EffectsProcessor *fx;
}
@end


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    AKOrchestra *orch = [[AKOrchestra alloc] init];
    toneGenerator = [[ToneGenerator alloc] init];
    fx = [[EffectsProcessor alloc] initWithAudioSource:toneGenerator.auxilliaryOutput];
    
    [orch addInstrument:toneGenerator];
    [orch addInstrument:fx];
    
    [[AKManager sharedAKManager] runOrchestra:orch];
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
