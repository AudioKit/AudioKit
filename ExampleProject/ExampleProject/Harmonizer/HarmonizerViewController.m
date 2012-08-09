//
//  HarmonizerViewController.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "HarmonizerViewController.h"
#import "Helper.h"
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
    //[conv playNoteForDuration:150000];
    OCSEvent *playback = [[OCSEvent alloc] initWithInstrument:harmonizer];
    [playback trigger];
}

-(IBAction)changePitch:(id)sender 
{
    harmonizer.pitch.value = [Helper scaleValueFromSlider:sender 
                                                  minimum:kPitchMin 
                                                  maximum:kPitchMax];
    
}
-(IBAction)changeGain:(id)sender;
{
    harmonizer.gain.value = [Helper scaleValueFromSlider:sender 
                                                      minimum:kGainMin 
                                                      maximum:kGainMax];
    
}



@end
