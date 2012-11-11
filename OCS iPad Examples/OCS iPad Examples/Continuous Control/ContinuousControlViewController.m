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
    
    [amplitudeLabel  setText:[NSString stringWithFormat:@"%f", myTweakableInstrument.amplitude.value]];
    [modulationLabel setText:[NSString stringWithFormat:@"%f", myTweakableInstrument.modulation.value]];
    [modIndexLabel   setText:[NSString stringWithFormat:@"%f", myTweakableInstrument.modIndex.value]];
    
    [OCSiOSTools setSlider:amplitudeSlider  usingProperty:[myTweakableInstrument amplitude]];
    [OCSiOSTools setSlider:modulationSlider usingProperty:[myTweakableInstrument modulation]];
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

- (void)noteTimerFire:(NSTimer *)timer
{
    [myTweakableInstrument.frequency randomize];
}



- (void)sliderTimerFire:(NSTimer *)timer
{
    [myTweakableInstrument.modIndex randomize];
    [OCSiOSTools setSlider:modIndexSlider 
            withValue:myTweakableInstrument.modIndex.value
              minimum:kTweakableModIndexMin 
              maximum:kTweakableModIndexMax];
    
    [modIndexLabel   setText:[NSString stringWithFormat:@"%f", myTweakableInstrument.modIndex.value]];

    // Test to show amplitude slider moving also
//    [self setSlider:amplitudeSlider
//          withValue:[[myTweakableInstrument amplitude] value]  
//            minimum:kTweakableAmplitudeMin 
//            maximum:kTweakableAmplitudeMax];

}


- (IBAction)scaleAmplitude:(id)sender {
    float newValue = [OCSiOSTools scaleValueFromSlider:sender
                                               minimum:kTweakableAmplitudeMin
                                               maximum:kTweakableAmplitudeMax];
    myTweakableInstrument.amplitude.value = newValue;
    [amplitudeLabel  setText:[NSString stringWithFormat:@"%f", newValue]];
    
}

- (IBAction)scaleModulation:(id)sender {
    float newValue = [OCSiOSTools scaleValueFromSlider:sender
                                               minimum:kTweakableModulationMin
                                               maximum:kTweakableModulationMax];
    myTweakableInstrument.modulation.value = newValue;
    [modulationLabel setText:[NSString stringWithFormat:@"%f", newValue]];
    
}

- (void)viewDidUnload {
    amplitudeLabel = nil;
    modulationLabel = nil;
    modIndexLabel = nil;
    [super viewDidUnload];
}
@end
