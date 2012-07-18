//
//  ContinuousControlViewController.m
//  Objective-Csound Example
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ContinuousControlViewController.h"
#import "Helper.h"
#import "OCSManager.h"


@interface ContinuousControlViewController ()
{
    TweakableInstrument *myTweakableInstrument;
    NSTimer *repeatingNoteTimer;
    NSTimer *repeatingSliderTimer;
    OCSEvent *currentEvent;
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
    currentEvent = nil;
    
    [Helper setSlider:amplitudeSlider  usingProperty:[myTweakableInstrument amplitude]];
    [Helper setSlider:modulationSlider usingProperty:[myTweakableInstrument modulation]];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [repeatingNoteTimer invalidate];
    repeatingNoteTimer = nil;
    [repeatingSliderTimer invalidate];
    repeatingSliderTimer = nil;
    //[[myTweakableInstrument myPropertyManager] closeMidiIn];
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
    float randomFrequency = [Helper randomFloatFrom:kTweakableFrequencyMin 
                                                 to:kTweakableFrequencyMax];
    
    currentEvent = [[OCSEvent alloc] initWithInstrument:myTweakableInstrument];
    [currentEvent setInstrumentProperty:[myTweakableInstrument frequency] toValue:randomFrequency];
    [currentEvent trigger];
    
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
    if (currentEvent) {
        OCSEvent *off = [[OCSEvent alloc] initDeactivation:currentEvent afterDuration:0];
        [off trigger];
    }
    [repeatingNoteTimer invalidate];
    repeatingNoteTimer = nil;
    [repeatingSliderTimer invalidate];
    repeatingSliderTimer = nil;
}

- (void)noteTimerFire:(NSTimer *)timer
{
    if (currentEvent) {
        OCSEvent *off = [[OCSEvent alloc] initDeactivation:currentEvent afterDuration:0];
        [off trigger];
    }
    float randomFrequency = [Helper randomFloatFrom:kTweakableFrequencyMin 
                                                 to:kTweakableFrequencyMax];
    currentEvent = [[OCSEvent alloc] initWithInstrument:myTweakableInstrument];
    [currentEvent setInstrumentProperty:[myTweakableInstrument frequency] toValue:randomFrequency];
    [currentEvent trigger];
}



- (void)sliderTimerFire:(NSTimer *)timer
{
    float newValue = [Helper randomFloatFrom:kTweakableModIndexMin 
                                          to:kTweakableModIndexMax];
    myTweakableInstrument.modIndex.value = newValue;
    [Helper setSlider:modIndexSlider 
            withValue:newValue 
              minimum:kTweakableModIndexMin 
              maximum:kTweakableModIndexMax];

    // Test to show amplitude slider moving also
//    [self setSlider:amplitudeSlider
//          withValue:[[myTweakableInstrument amplitude] value]  
//            minimum:kTweakableAmplitudeMin 
//            maximum:kTweakableAmplitudeMax];

}


- (IBAction)scaleAmplitude:(id)sender {
    float newValue = [Helper scaleValueFromSlider:sender 
                                          minimum:kTweakableAmplitudeMin 
                                          maximum:kTweakableAmplitudeMax];
    myTweakableInstrument.amplitude.value = newValue;
}

- (IBAction)scaleModulation:(id)sender {
    float newValue = [Helper scaleValueFromSlider:sender 
                                          minimum:kTweakableModulationMin 
                                          maximum:kTweakableModulationMax];
    myTweakableInstrument.modulation.value = newValue;
}

@end
