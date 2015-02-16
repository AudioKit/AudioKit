//
//  ProcessingViewController.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/14/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "ProcessingViewController.h"
#import "AKFoundation.h"
#import "AKTools.h"
#import "ConvolutionInstrument.h"
#import "AudioFilePlayer.h"
#import "AKAudioAnalyzer.h"



@implementation ProcessingViewController
{
    IBOutlet UISegmentedControl *sourceSegmentedControl;
    IBOutlet UISwitch *maintainPitchSwitch;
    IBOutlet UISlider *pitchSlider;
    
    float pitchToMaintain;
    
    ConvolutionInstrument *conv;
    AudioFilePlayer *audioFilePlayer;
    
    AKAudioAnalyzer *analyzer;
    AKSequence *continuouslyUpdateLevelMeter;
    AKEvent *updateLevelMeter;
}

- (void)viewDidAppear:(BOOL)animated    {
    [super viewDidAppear:animated];
    audioFilePlayer = [[AudioFilePlayer alloc] init];
    [AKOrchestra addInstrument:audioFilePlayer];
    
    conv = [[ConvolutionInstrument alloc] initWithInput:audioFilePlayer.auxilliaryOutput];
    [AKOrchestra addInstrument:conv];
    
    
    [[AKManager sharedManager] setIsLogging:YES];
    analyzer = [[AKAudioAnalyzer alloc] initWithAudioSource:conv.auxilliaryOutput];
    [AKOrchestra addInstrument:analyzer];
    
    [AKOrchestra start];
    [analyzer play];
    pitchToMaintain = 1.0;
}

- (void)viewWillDisappear:(BOOL)animated   {
    [super viewWillDisappear:animated];
    [AKOrchestra reset];
    [[AKManager sharedManager] stop];
}


- (IBAction)start:(id)sender {
    [conv play];
    [audioFilePlayer play];
}

- (IBAction)stop:(id)sender {
    [audioFilePlayer stop];
    [conv stop];
}

- (IBAction)wetnessChanged:(UISlider *)sender {
    [AKTools setProperty:conv.dryWetBalance withSlider:sender];
}

- (IBAction)impulseResponseChanged:(UISlider *)sender {
    [AKTools setProperty:conv.dishWellBalance withSlider:sender];
}
- (IBAction)speedChanged:(UISlider *)sender
{
    [AKTools setProperty:audioFilePlayer.speed withSlider:sender];
    if (maintainPitchSwitch.isOn && fabs(audioFilePlayer.speed.value) > 0.1) {
        audioFilePlayer.scaling.value =  pitchToMaintain / fabs(audioFilePlayer.speed.value);
        [AKTools setSlider:pitchSlider withProperty:audioFilePlayer.scaling];
    }
}
- (IBAction)pitchChanged:sender {
    [AKTools setProperty:audioFilePlayer.scaling withSlider:sender];
}
- (IBAction)togglePitchMaintenance:(UISwitch *)sender {
    if (sender.isOn) {
        [pitchSlider setEnabled:NO];
        pitchToMaintain = fabs(audioFilePlayer.speed.value) * audioFilePlayer.scaling.value;
    } else {
        [pitchSlider setEnabled:YES];
    }
}
- (IBAction)fileChanged:(UISegmentedControl *)sender {
    audioFilePlayer.sampleMix.value = (float) sender.selectedSegmentIndex;    
}

@end
