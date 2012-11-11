//
//  HarmonizerViewController.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "HarmonizerViewController.h"
#import "OCSiOSTools.h"
#import "OCSManager.h"
#import "Harmonizer.h"

@interface HarmonizerViewController () {
    Harmonizer *harmonizer;
}
@end

@implementation HarmonizerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];
    harmonizer = [[Harmonizer alloc] init];
    [orch addInstrument:harmonizer];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (IBAction)start:(id)sender
{
    [harmonizer play];
}

-(IBAction)changePitch:(id)sender
{
    harmonizer.pitch.value = [OCSiOSTools scaleValueFromSlider:sender
                                                       minimum:kPitchMin
                                                       maximum:kPitchMax];
    
}
-(IBAction)changeGain:(id)sender;
{
    harmonizer.gain.value = [OCSiOSTools scaleValueFromSlider:sender
                                                      minimum:kGainMin
                                                      maximum:kGainMax];
    
}



@end
