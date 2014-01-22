//
//  HarmonizerViewController.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "HarmonizerViewController.h"
#import "AKiOSTools.h"
#import "AKManager.h"
#import "Harmonizer.h"

@interface HarmonizerViewController () {
    Harmonizer *harmonizer;
}
@end

@implementation HarmonizerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AKOrchestra *orch = [[AKOrchestra alloc] init];
    harmonizer = [[Harmonizer alloc] init];
    [orch addInstrument:harmonizer];
    [[AKManager sharedAKManager] runOrchestra:orch];
}

- (IBAction)start:(id)sender {
    [harmonizer play];
}

- (IBAction)changePitch:(id)sender {
    [AKiOSTools setProperty:harmonizer.pitch withSlider:(UISlider *)sender];
}

- (IBAction)changeGain:(id)sender {
    [AKiOSTools setProperty:harmonizer.gain withSlider:(UISlider *)sender];
}

@end
