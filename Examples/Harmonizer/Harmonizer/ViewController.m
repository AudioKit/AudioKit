//
//  ViewController.m
//  Harmonizer
//
//  Created by Aurelius Prochazka on 7/6/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "ViewController.h"
#import "AKFoundation.h"
#import "HarmonizerInstrument.h"

@interface ViewController () {
    HarmonizerInstrument *harmonizer;
    AKSampler *sampler;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    AKOrchestra *orchestra = [[AKOrchestra alloc] init];
    harmonizer = [[HarmonizerInstrument alloc] init];
    [orchestra addInstrument:harmonizer];
    
    [[AKManager sharedAKManager] runOrchestra:orchestra];
    sampler = [[AKSampler alloc] init];
    
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
