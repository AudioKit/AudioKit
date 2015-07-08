//
//  ProcessingViewController.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/23/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "ProcessingViewController.h"

#import "AKFoundation.h"
#import "ConvolutionInstrument.h"

@implementation ProcessingViewController
{
    IBOutlet NSSegmentedControl *sourceSegmentedControl;
    IBOutlet NSButton *maintainPitchSwitch;
    IBOutlet AKPropertySlider *speedSlider;
    IBOutlet AKPropertySlider *pitchSlider;
    IBOutlet AKPropertySlider *dishWellSlider;
    IBOutlet AKPropertySlider *dryWetSlider;

    float pitchToMaintain;

    ConvolutionInstrument *convolver;
    AKAudioFilePlayer *audioFilePlayer;

    BOOL isPlaying;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    audioFilePlayer = [[AKAudioFilePlayer alloc] init];
    [AKOrchestra addInstrument:audioFilePlayer];

    convolver = [[ConvolutionInstrument alloc] initWithInput:audioFilePlayer.output];
    [AKOrchestra addInstrument:convolver];

    speedSlider.property = audioFilePlayer.speed;
    pitchSlider.property = audioFilePlayer.scaling;
    dishWellSlider.property = convolver.dishWellBalance;
    dryWetSlider.property   = convolver.dryWetBalance;

    pitchToMaintain = 1.0;
    isPlaying = NO;
}

- (void)viewWillDisappear {
    [self stop:self];
}


- (IBAction)start:(id)sender {
    if (!isPlaying) {
        [convolver start];
        [audioFilePlayer play];
        isPlaying = YES;
    }
}

- (IBAction)stop:(id)sender {
    if (isPlaying) {
        [audioFilePlayer stop];
        [convolver stop];
        isPlaying = NO;
    }
}

- (IBAction)speedChanged:(NSSlider *)sender
{
    if (maintainPitchSwitch.state == NSOnState && fabs(audioFilePlayer.speed.value) > 0.1) {
        audioFilePlayer.scaling.value =  pitchToMaintain / fabs(audioFilePlayer.speed.value);
        [AKTools setSlider:pitchSlider withProperty:audioFilePlayer.scaling];
    }
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
