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
#import "AudioFilePlayer.h"

@implementation ProcessingViewController
{
    IBOutlet NSSegmentedControl *sourceSegmentedControl;
    IBOutlet NSButton *maintainPitchSwitch;
    IBOutlet NSSlider *pitchSlider;
    
    float pitchToMaintain;
    
    ConvolutionInstrument *convolver;
    AudioFilePlayer *audioFilePlayer;
    
    BOOL isPlaying;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    audioFilePlayer = [[AudioFilePlayer alloc] init];
    [AKOrchestra addInstrument:audioFilePlayer];
    
    convolver = [[ConvolutionInstrument alloc] initWithInput:audioFilePlayer.auxilliaryOutput];
    [AKOrchestra addInstrument:convolver];
    
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

- (IBAction)wetnessChanged:(NSSlider *)sender {
    [AKTools setProperty:convolver.dryWetBalance withSlider:sender];
}

- (IBAction)impulseResponseChanged:(NSSlider *)sender {
    [AKTools setProperty:convolver.dishWellBalance withSlider:sender];
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
