//
//  ContinuousControlViewController.m
//  AudioKit Example
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ContinuousControlViewController.h"
#import "AKiOSTools.h"
#import "AKManager.h"


@interface ContinuousControlViewController ()
{
    TweakableInstrument *myTweakableInstrument;
    NSTimer *repeatingNoteTimer;
    NSTimer *repeatingSliderTimer;
}
@end

@implementation ContinuousControlViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    AKOrchestra *orch = [[AKOrchestra alloc] init];
    myTweakableInstrument = [[TweakableInstrument alloc] init];
    [orch addInstrument:myTweakableInstrument];
    [[AKManager sharedAKManager] runOrchestra:orch];
    
    [AKiOSTools setLabel:amplitudeLabel  withProperty:myTweakableInstrument.amplitude];
    [AKiOSTools setLabel:modulationLabel withProperty:myTweakableInstrument.modulation];
    [AKiOSTools setLabel:modIndexLabel   withProperty:myTweakableInstrument.modIndex];
    
    [AKiOSTools setSlider:amplitudeSlider  withProperty:myTweakableInstrument.amplitude];
    [AKiOSTools setSlider:modulationSlider withProperty:myTweakableInstrument.modulation];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [repeatingNoteTimer invalidate];
    repeatingNoteTimer = nil;
    [repeatingSliderTimer invalidate];
    repeatingSliderTimer = nil;
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
    [AKiOSTools setSlider:modIndexSlider withProperty:myTweakableInstrument.modIndex];
    [AKiOSTools setLabel:modIndexLabel   withProperty:myTweakableInstrument.modIndex];
    // Test to show amplitude slider moving also
    //[AKiOSTools setSlider:amplitudeSlider withProperty:myTweakableInstrument.amplitude];
}


- (IBAction)scaleAmplitude:(id)sender {
    [AKiOSTools setProperty:myTweakableInstrument.amplitude withSlider:(UISlider *)sender];
    [AKiOSTools setLabel:amplitudeLabel  withProperty:myTweakableInstrument.amplitude];
}

- (IBAction)scaleModulation:(id)sender {
    [AKiOSTools setProperty:myTweakableInstrument.modulation withSlider:(UISlider *)sender];
    [AKiOSTools setLabel:modulationLabel  withProperty:myTweakableInstrument.modulation];
}

- (void)viewDidUnload {
    amplitudeLabel = nil;
    modulationLabel = nil;
    modIndexLabel = nil;
    [super viewDidUnload];
}
@end
