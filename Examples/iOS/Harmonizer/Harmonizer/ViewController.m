//
//  ViewController.m
//  Harmonizer
//
//  Created by Aurelius Prochazka on 7/6/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "ViewController.h"
#import "AKFoundation.h"
#import "HarmonizerInstrument.h"

@implementation ViewController
{
    HarmonizerInstrument *harmonizer;
    AKSampler *sampler;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    sampler = [[AKSampler alloc] init];
    harmonizer = [[HarmonizerInstrument alloc] init];
    [AKOrchestra addInstrument:harmonizer];
    [AKOrchestra start];
}

- (IBAction)startRecording:(id)sender {
    [harmonizer play];
    [sampler startRecordingToTrack:@"harmonizer"];
}
- (IBAction)stopRecording:(id)sender {
    [harmonizer stop];
    [sampler stopRecordingToTrack:@"harmonizer"];
}

- (IBAction)startPlaying:(id)sender {
    [sampler startPlayingTrack:@"harmonizer"];
}
- (IBAction)stopPlaying:(id)sender {
    [sampler stopPlayingTrack:@"harmonizer"];
}

@end
