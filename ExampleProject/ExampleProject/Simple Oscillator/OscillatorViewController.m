//
//  OscillatorViewController.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OscillatorViewController.h"
#import "OCSManager.h"
#import "SoundGenerator.h"

@interface OscillatorViewController () {
    SoundGenerator *mySoundGenerator;
}
@end
@implementation OscillatorViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];    
    mySoundGenerator =  [[SoundGenerator alloc] init];
    [orch addInstrument:mySoundGenerator];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (IBAction)playA:(id)sender {
    [mySoundGenerator playNoteForDuration:1 frequency:440];
}

- (IBAction)playRandomFrequency:(id)sender {
    float randomFrequency = randomFloatBetween(kFrequencyMin, kFrequencyMax);
    [mySoundGenerator playNoteForDuration:1 frequency:randomFrequency];
}

@end
