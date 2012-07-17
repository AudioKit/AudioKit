//
//  MidifiedInstrumentViewController.m
//  Objective-Csound
//
//  Created by Adam Boulanger on 7/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "MidifiedInstrumentViewController.h"
#import "OCSManager.h"
#import "MidifiedInstrument.h"
#import "Helper.h"

@interface MidifiedInstrumentViewController () {
    MidifiedInstrument *midifiedFm;
    OCSOrchestra *orch;
}

@end

@implementation MidifiedInstrumentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    orch = [[OCSOrchestra alloc] init];
    midifiedFm = [[MidifiedInstrument alloc] init];
    [orch addInstrument:midifiedFm];
    
    [self initUIElements];

    [[OCSManager sharedOCSManager] enableMidi];
    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (void)viewDidUnload
{
    frequencyLabel = nil;
    modulationLabel = nil;
    midiCutoffLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
    
    //[[OCSManager sharedOCSManager] disableMidi];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)initUIElements
{
    
    [frequencySlider setMinimumValue:kFrequencyMin];
    [frequencySlider setMaximumValue:kFrequencyMax];
    frequencySlider.value = midifiedFm.frequency.value;
    [frequencyLabel setText:[NSString stringWithFormat:@"%g", midifiedFm.frequency.value]];
    [modulationSlider setMinimumValue:kModulationMin];
    [modulationSlider setMaximumValue:kModulationMax];
    modulationSlider.value = midifiedFm.modulation.value;
    [modulationLabel setText:[NSString stringWithFormat:@"%g", midifiedFm.modulation.value]];
}

-(IBAction)noteOnOff:(id)sender
{
    UISwitch *s = sender;
    if(s.on) {
        [midifiedFm playNoteForDuration:10000];
    } else {
        [[OCSManager sharedOCSManager] stop];
    }
}

-(IBAction)moveFrequencySlider:(id)sender
{
    int freq = [Helper scaleValueFromSlider:sender minimum:kFrequencyMin maximum:kFrequencyMax];
    [frequencyLabel setText:[NSString stringWithFormat:@"%d", freq]];
    midifiedFm.frequency.value = freq;
}

-(IBAction)moveModulationSlider:(id)sender
{
    float mod = [Helper scaleValueFromSlider:sender minimum:kModulationMin maximum:kModulationMax];
    [modulationLabel setText:[NSString stringWithFormat:@"%.02g", mod]];
    midifiedFm.modulation.value = mod;
}

-(IBAction)midiPanic:(id)sender
{
    [[OCSManager sharedOCSManager] panic];
    noteOnSwitch.on = FALSE;
}

@end
