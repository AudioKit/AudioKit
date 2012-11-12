//
//  ContinuousControlViewController.m
//  Objective-C Sound Example
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ContinuousControlViewController.h"
#import "OCSiOSTools.h"
#import "OCSManager.h"


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
    
    OCSOrchestra * orch = [[OCSOrchestra alloc] init];
    myTweakableInstrument = [[TweakableInstrument alloc] init];
    [orch addInstrument:myTweakableInstrument];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
    
    [OCSiOSTools setLabel:amplitudeLabel  withProperty:myTweakableInstrument.amplitude];
    [OCSiOSTools setLabel:modulationLabel withProperty:myTweakableInstrument.modulation];
    [OCSiOSTools setLabel:modIndexLabel   withProperty:myTweakableInstrument.modIndex];
    
    [OCSiOSTools setSlider:amplitudeSlider  withProperty:myTweakableInstrument.amplitude];
    [OCSiOSTools setSlider:modulationSlider withProperty:myTweakableInstrument.modulation];
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
    [OCSiOSTools setSlider:modIndexSlider withProperty:myTweakableInstrument.modIndex];
    [OCSiOSTools setLabel:modIndexLabel   withProperty:myTweakableInstrument.modIndex];
    // Test to show amplitude slider moving also
    //[OCSiOSTools setSlider:amplitudeSlider withProperty:myTweakableInstrument.amplitude];
}


- (IBAction)scaleAmplitude:(id)sender {
    [OCSiOSTools setProperty:myTweakableInstrument.amplitude withSlider:(UISlider *)sender];
    [OCSiOSTools setLabel:amplitudeLabel  withProperty:myTweakableInstrument.amplitude];
}

- (IBAction)scaleModulation:(id)sender {
    [OCSiOSTools setProperty:myTweakableInstrument.modulation withSlider:(UISlider *)sender];
    [OCSiOSTools setLabel:amplitudeLabel  withProperty:myTweakableInstrument.modulation];
}

- (void)viewDidUnload {
    amplitudeLabel = nil;
    modulationLabel = nil;
    modIndexLabel = nil;
    [super viewDidUnload];
}
@end
