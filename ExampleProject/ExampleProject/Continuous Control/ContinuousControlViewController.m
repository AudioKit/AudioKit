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
    
    float minValue    = [[myTweakableInstrument amplitude] minimumValue];
    float maxValue    = [[myTweakableInstrument amplitude] maximumValue];
    float actualValue = [[myTweakableInstrument amplitude] value];
    float sliderValue = (actualValue-minValue)/(maxValue-minValue)* 100.0;
    [amplitudeSlider setValue:sliderValue];

    minValue    = [[myTweakableInstrument modulation] minimumValue];
    maxValue    = [[myTweakableInstrument modulation] maximumValue];
    actualValue = [[myTweakableInstrument modulation] value];
    sliderValue = (actualValue-minValue)/(maxValue-minValue)* 100.0;
    [modulationSlider setValue:sliderValue];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [repeatingNoteTimer invalidate];
    repeatingNoteTimer = nil;
    [repeatingSliderTimer invalidate];
    repeatingSliderTimer = nil;
    //[[myTweakableInstrument myPropertyManager] closeMidiIn];
}

- (IBAction)runInstrument:(id)sender
{
    float randomFrequency = [Helper randomFloatFrom:kTweakableFrequencyMin 
                                                 to:kTweakableFrequencyMax];
    [myTweakableInstrument playNoteForDuration:3.0 Frequency:randomFrequency];
    
    if (repeatingNoteTimer) {
        return;
    } else {
        repeatingNoteTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 
                                                              target:self      
                                                            selector:@selector(noteTimerFire:)   
                                                            userInfo:nil 
                                                             repeats:YES];
        repeatingSliderTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 
                                                                target:self 
                                                              selector:@selector(sliderTimerFire:) 
                                                              userInfo:nil 
                                                               repeats:YES];
    }
}

- (IBAction)stopInstrument:(id)sender
{
    [repeatingNoteTimer invalidate];
    repeatingNoteTimer = nil;
    [repeatingSliderTimer invalidate];
    repeatingSliderTimer = nil;
}

- (void)noteTimerFire:(NSTimer *)timer
{
    float randomFrequency = [Helper randomFloatFrom:kTweakableFrequencyMin 
                                                 to:kTweakableFrequencyMax];
    [myTweakableInstrument playNoteForDuration:3.0 Frequency:randomFrequency];
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
