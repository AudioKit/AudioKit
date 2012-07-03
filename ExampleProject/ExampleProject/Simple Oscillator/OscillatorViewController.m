//
//  OscillatorViewController.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 5/30/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OscillatorViewController.h"
#import "Helper.h"
#import "OCSManager.h"
#import "SoundGenerator.h"

@interface OscillatorViewController () {
    SoundGenerator *mySoundGenerator;
}
@end
@implementation OscillatorViewController
@synthesize frequencyLabel;

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
    [frequencyLabel setText:[NSString stringWithFormat:@"%g", 440.0]];
    [mySoundGenerator playNoteForDuration:1 frequency:440];
}

- (IBAction)playRandomFrequency:(id)sender {
    float randomFrequency = [Helper randomFloatFrom:kFrequencyMin to:kFrequencyMax];
    [frequencyLabel setText:[NSString stringWithFormat:@"%g", randomFrequency]];
    [mySoundGenerator playNoteForDuration:1 frequency:randomFrequency];
}

- (void)viewDidUnload {
    [self setFrequencyLabel:nil];
    [super viewDidUnload];
}
@end
