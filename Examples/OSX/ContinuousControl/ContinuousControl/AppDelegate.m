//
//  AppDelegate.m
//  ContinuousControl
//
//  Created by Aurelius Prochazka on 8/3/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AppDelegate.h"
#import "AKFoundation.h"
#import "AKOSXTools.h"
#import "TweakableInstrument.h"

@interface AppDelegate ()
{
    IBOutlet NSSlider *amplitudeSlider;
    IBOutlet NSSlider *modulationSlider;
    IBOutlet NSSlider *modIndexSlider;
    IBOutlet NSTextField *amplitudeLabel;
    IBOutlet NSTextField *modulationLabel;
    IBOutlet NSTextField *modIndexLabel;
    
    TweakableInstrument *myTweakableInstrument;
    NSTimer *repeatingNoteTimer;
    NSTimer *repeatingSliderTimer;
}
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    AKOrchestra *orch = [[AKOrchestra alloc] init];
    myTweakableInstrument = [[TweakableInstrument alloc] init];
    [orch addInstrument:myTweakableInstrument];
    [[AKManager sharedAKManager] runOrchestra:orch];
    
    [AKOSXTools setTextField:amplitudeLabel  withProperty:myTweakableInstrument.amplitude];
    [AKOSXTools setTextField:modulationLabel withProperty:myTweakableInstrument.modulation];
    [AKOSXTools setTextField:modIndexLabel   withProperty:myTweakableInstrument.modIndex];
    
    [AKOSXTools setSlider:amplitudeSlider  withProperty:myTweakableInstrument.amplitude];
    [AKOSXTools setSlider:modulationSlider withProperty:myTweakableInstrument.modulation];
}


- (id)schedule:(SEL)selector
    afterDelay:(float)delayTime;
{
    return [NSTimer scheduledTimerWithTimeInterval:delayTime
                                            target:self
                                          selector:selector
                                          userInfo:nil
                                           repeats:YES];
}

- (IBAction)runInstrument:(id)sender
{
    [myTweakableInstrument play];
    [myTweakableInstrument.frequency randomize];
    
    if (repeatingNoteTimer) {
        return;
    } else {
        repeatingNoteTimer = [self schedule:@selector(noteTimerFire:)
                                 afterDelay:3.0f];
        repeatingSliderTimer = [self schedule:@selector(sliderTimerFire:)
                                   afterDelay:0.2f];
        [[NSRunLoop currentRunLoop] addTimer:repeatingNoteTimer   forMode:NSEventTrackingRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:repeatingSliderTimer forMode:NSEventTrackingRunLoopMode];
    }
}

- (IBAction)stopInstrument:(id)sender
{
    [myTweakableInstrument stop];
    [repeatingNoteTimer invalidate];
    repeatingNoteTimer = nil;
    [repeatingSliderTimer invalidate];
    repeatingSliderTimer = nil;
}

- (void)noteTimerFire:(NSTimer *)timer {
    [myTweakableInstrument.frequency randomize];
}

- (void)sliderTimerFire:(NSTimer *)timer
{
    [myTweakableInstrument.modIndex randomize];
    [AKOSXTools setSlider:modIndexSlider withProperty:myTweakableInstrument.modIndex];
    [AKOSXTools setTextField:modIndexLabel withProperty:myTweakableInstrument.modIndex];
    // Test to show amplitude slider moving also
    //[AKOSXTools setSlider:amplitudeSlider withProperty:myTweakableInstrument.amplitude];
}


- (IBAction)scaleAmplitude:(id)sender {
    [AKOSXTools setProperty:myTweakableInstrument.amplitude withSlider:(NSSlider *)sender];
    [AKOSXTools setTextField:amplitudeLabel withProperty:myTweakableInstrument.amplitude];
}

- (IBAction)scaleModulation:(id)sender {
    [AKOSXTools setProperty:myTweakableInstrument.modulation withSlider:(NSSlider *)sender];
    [AKOSXTools setTextField:modulationLabel withProperty:myTweakableInstrument.modulation];
}



@end

