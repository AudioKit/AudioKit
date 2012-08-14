//
//  MidiViewController.m
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 8/11/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "MidiViewController.h"
#import "OCSManager.h"
#import "FivePropertyInstrument.h"
#import "Helper.h"

@interface MidiViewController () <OCSMidiListener> {
    int _channel;
    int _note;
    int _modulation;
    int _pitchBend;
    int _controllerNumber;
    int _controllerValue;
    FivePropertyInstrument *instrument;
    OCSOrchestra *orch;
    NSMutableDictionary *currentNotes;
}
@end

@implementation MidiViewController

- (void)updateUI {
    [channelLabel setText:[NSString stringWithFormat:@"%i", _channel]];
    [noteLabel setText:[NSString stringWithFormat:@"%i", _note]];
    
    [modulationLabel setText:[NSString stringWithFormat:@"%i", _modulation]];
    [Helper setSlider:modulationSlider
            withValue:_modulation
              minimum:0
              maximum:127];
    
    [pitchBendLabel setText:[NSString stringWithFormat:@"%i", _pitchBend]];
    [Helper setSlider:pitchBendSlider
            withValue:_pitchBend
              minimum:0
              maximum:powf(2.0, 14.0)];
    
    if (_controllerNumber > 1) {
        [controllerNumberLabel setText:[NSString stringWithFormat:@"CC# %i", _controllerNumber]];
        [controllerValueLabel  setText:[NSString stringWithFormat:@"%i", _controllerValue]];
        [Helper setSlider:controllerSlider
                withValue:_controllerValue
                  minimum:0
                  maximum:127];
    }
}

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"Respond to MIDI", @"Respond to MIDI");
    _channel = 1;
    _note = 0;
    _modulation = 0;
    _pitchBend = 8192;
    _controllerNumber = 0;
    _controllerValue = 0;
    currentNotes = [[NSMutableDictionary alloc] init];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    orch = [[OCSOrchestra alloc] init];
    instrument = [[FivePropertyInstrument alloc] init];
    [orch addInstrument:instrument];

    [[OCSManager sharedOCSManager] runOrchestra:orch];
    [[OCSManager sharedOCSManager] enableMidi];
    [[[OCSManager sharedOCSManager] midi] addListener:self];
}

- (void)viewDidUnload
{
    controllerNumberLabel = nil;
    controllerValueLabel = nil;
    controllerSlider = nil;
    channelLabel = nil;
    noteLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)midiNoteOn:(int)note velocity:(int)velocity channel:(int)channel {
    _channel = channel;
    _note    = note;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
    
    OCSEvent *noteOnEvent = [[OCSEvent alloc] initWithInstrument:instrument];
    [noteOnEvent setNoteProperty:[instrument frequency] toValue:[Helper midiNoteToFrequency:note]];
    float volume = [Helper scaleValue:velocity
                          fromMinimum:0
                          fromMaximum:127
                            toMinimum:kVolumeMin
                            toMaximum:kVolumeMax];
    [noteOnEvent setNoteProperty:[instrument volume] toValue:volume];
    [noteOnEvent trigger];
    [currentNotes setObject:noteOnEvent forKey:[NSNumber numberWithInt:note]];
}

- (void)midiNoteOff:(int)note velocity:(int)velocity channel:(int)channel
{
    _channel = channel;
    _note    = note;
    OCSEvent *noteOnEvent = [currentNotes objectForKey:[NSNumber numberWithInt:note]];
    OCSEvent *noteOffEvent = [[OCSEvent alloc] initDeactivation:noteOnEvent afterDuration:0];
    [noteOffEvent trigger];
}
    

- (void)midiController:(int)controller changedToValue:(int)value channel:(int)channel {
    _channel = channel;
    _controllerNumber = controller;
    _controllerValue = value;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
    
    OCSEvent *cutOffChange = [[OCSEvent alloc] initWithInstrument:instrument];
    float cutoff = [Helper scaleValue:value
                          fromMinimum:0
                          fromMaximum:127
                            toMinimum:kLpCutoffMax
                            toMaximum:kLpCutoffMin];
    [cutOffChange setInstrumentProperty:[instrument cutoffFrequency] toValue:cutoff];
}

- (void)midiPitchWheel:(int)pitchWheelValue channel:(int)channel {
    _channel = channel;
    _pitchBend = pitchWheelValue;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
}

- (void)midiModulation:(int)modulation channel:(int)channel {
    _channel = channel;
    _modulation = modulation;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
    
    OCSEvent *modulationChange = [[OCSEvent alloc] initWithInstrument:instrument];
    float mod = [Helper scaleValue:modulation
                       fromMinimum:0
                       fromMaximum:127
                         toMinimum:kModulationMin
                         toMaximum:kModulationMax];
    [modulationChange setInstrumentProperty:[instrument modulation] toValue:mod];
}



@end
