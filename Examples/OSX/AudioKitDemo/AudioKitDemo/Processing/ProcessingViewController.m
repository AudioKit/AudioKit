//
//  ProcessingViewController.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/23/15.
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
    IBOutlet NSSegmentedControl *sourceSegmentedControl;
    IBOutlet NSButton *maintainPitchSwitch;
    IBOutlet NSSlider *pitchSlider;
    
    float pitchToMaintain;
    
    ConvolutionInstrument *conv;
    AudioFilePlayer *audioFilePlayer;
    
    AKAudioAnalyzer *analyzer;
    AKSequence *continuouslyUpdateLevelMeter;
    AKEvent *updateLevelMeter;
}

- (void)viewDidAppear {
    [super viewDidAppear];
    audioFilePlayer = [[AudioFilePlayer alloc] init];
    [AKOrchestra addInstrument:audioFilePlayer];
    
    conv = [[ConvolutionInstrument alloc] initWithInput:audioFilePlayer.auxilliaryOutput];
    [AKOrchestra addInstrument:conv];
    
    analyzer = [[AKAudioAnalyzer alloc] initWithAudioSource:conv.auxilliaryOutput];
    [AKOrchestra addInstrument:analyzer];
    
    [AKOrchestra start];
    [analyzer play];
    pitchToMaintain = 1.0;
}

- (void)viewWillDisappear {
    [super viewWillDisappear];
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

- (IBAction)wetnessChanged:(NSSlider *)sender {
    [AKTools setProperty:conv.dryWetBalance withSlider:sender];
}

- (IBAction)impulseResponseChanged:(NSSlider *)sender {
    [AKTools setProperty:conv.dishWellBalance withSlider:sender];
}
- (IBAction)speedChanged:(NSSlider *)sender
{
    [AKTools setProperty:audioFilePlayer.speed withSlider:sender];
    if (maintainPitchSwitch.state == NSOnState && fabs(audioFilePlayer.speed.value) > 0.1) {
        audioFilePlayer.scaling.value =  pitchToMaintain / fabs(audioFilePlayer.speed.value);
        [AKTools setSlider:pitchSlider withProperty:audioFilePlayer.scaling];
    }
}
- (IBAction)pitchChanged:(id)sender {
    [AKTools setProperty:audioFilePlayer.scaling withSlider:sender];
}
- (IBAction)togglePitchMaintenance:(NSButton *)sender {
    if (sender.state == NSOnState) {
        [pitchSlider setEnabled:NO];
        pitchToMaintain = fabs(audioFilePlayer.speed.value) * audioFilePlayer.scaling.value;
    } else {
        [pitchSlider setEnabled:YES];
    }
}
- (IBAction)fileChanged:(NSSegmentedControl *)sender {
    audioFilePlayer.sampleMix.value = (float) sender.selectedSegment;
}

@end
