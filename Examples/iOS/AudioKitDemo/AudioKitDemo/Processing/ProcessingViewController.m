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



@implementation ProcessingViewController
{
    IBOutlet UISegmentedControl *sourceSegmentedControl;
    IBOutlet UISwitch *maintainPitchSwitch;
    IBOutlet UISlider *pitchSlider;
    
    float pitchToMaintain;
    
    ConvolutionInstrument *convolver;
    AudioFilePlayer *audioFilePlayer;
    
    AKSequence *continuouslyUpdateLevelMeter;
    AKEvent *updateLevelMeter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    audioFilePlayer = [[AudioFilePlayer alloc] init];
    [AKOrchestra addInstrument:audioFilePlayer];
    
    convolver = [[ConvolutionInstrument alloc] initWithInput:audioFilePlayer.auxilliaryOutput];
    [AKOrchestra addInstrument:convolver];
    pitchToMaintain = 1.0;
}

- (void)viewWillDisappear:(BOOL)animated   {
    [super viewWillDisappear:animated];
    [self stop:self];
}


- (IBAction)start:(id)sender {
    [convolver start];
    [audioFilePlayer play];
}

- (IBAction)stop:(id)sender {
    [audioFilePlayer stop];
    [convolver stop];
}

- (IBAction)wetnessChanged:(UISlider *)sender {
    [AKTools setProperty:convolver.dryWetBalance withSlider:sender];
}

- (IBAction)impulseResponseChanged:(UISlider *)sender {
    [AKTools setProperty:convolver.dishWellBalance withSlider:sender];
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
