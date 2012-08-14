//
//  MIDIController.m
//  OCS Mac Examples
//
//  Created by Aurelius Prochazka on 8/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "MIDIController.h"
#import "OCSManager.h"
#import "FivePropertyInstrument.h"
#import "Helper.h"


@interface MIDIController () <OCSMidiListener> {
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

@implementation MIDIController
@synthesize pitchBendSlider;
@synthesize controllerSlider;
@synthesize modulationSlider;
@synthesize pitchBendLabel;
@synthesize noteLabel;
@synthesize channelLabel;
@synthesize controllerNumberLabel;
@synthesize controllerValueLabel;
@synthesize modulationLabel;

- (IBAction)enableMIDI:(id)sender {
    _channel = 1;
    _note = 0;
    _modulation = 0;
    _pitchBend = 8192;
    _controllerNumber = 0;
    _controllerValue = 0;
    
    orch = [[OCSOrchestra alloc] init];
    instrument = [[FivePropertyInstrument alloc] init];
    [orch addInstrument:instrument];
    
    [[OCSManager sharedOCSManager] runOrchestra:orch];
    [[OCSManager sharedOCSManager] enableMidi];
    [[[OCSManager sharedOCSManager] midi] addListener:self];
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
    NSLog(@"MIDI Note Off");
}


- (void)midiController:(int)controller changedToValue:(int)value channel:(int)channel {
    _channel = channel;
    _controllerNumber = controller;
    _controllerValue = value;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
    
    float cutoff = [Helper scaleControllerValue:value
                                    fromMinimum:kLpCutoffMax
                                      toMaximum:kLpCutoffMin];
    [[instrument cutoffFrequency] setValue:cutoff];
}

- (void)midiPitchWheel:(int)pitchWheelValue channel:(int)channel {
    _channel = channel;
    _pitchBend = pitchWheelValue;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
    
    float bend;
    if (pitchWheelValue <=8192) {
        bend = [Helper scaleValue:pitchWheelValue
                      fromMinimum:0
                      fromMaximum:8192
                        toMinimum:kPitchBendMin
                        toMaximum:1];
    } else {
        bend = [Helper scaleValue:pitchWheelValue
                      fromMinimum:8192
                      fromMaximum:16384
                        toMinimum:1
                        toMaximum:kPitchBendMax];
    }
    [[instrument pitchBend] setValue:bend];
}

- (void)midiModulation:(int)modulation channel:(int)channel {
    _channel = channel;
    _modulation = modulation;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
    
    float mod = [Helper scaleControllerValue:modulation
                                 fromMinimum:kModulationMin
                                   toMaximum:kModulationMax];
    [[instrument modulation] setValue:mod];
}

- (void)updateUI {
    [channelLabel setAttributedStringValue:[NSString stringWithFormat:@"%i", _channel]];
    [noteLabel setAttributedStringValue:[NSString stringWithFormat:@"%i", _note]];
    
    [modulationLabel setAttributedStringValue:[NSString stringWithFormat:@"%i", _modulation]];
    [Helper setSlider:modulationSlider
            withValue:_modulation
              minimum:0
              maximum:127];
    
    [pitchBendLabel setAttributedStringValue:[NSString stringWithFormat:@"%i", _pitchBend]];
    [Helper setSlider:pitchBendSlider
            withValue:_pitchBend
              minimum:0
              maximum:powf(2.0, 14.0)];
    
    if (_controllerNumber > 1) {
        [controllerNumberLabel setAttributedStringValue:[NSString stringWithFormat:@"CC# %i", _controllerNumber]];
        [controllerValueLabel  setAttributedStringValue:[NSString stringWithFormat:@"%i", _controllerValue]];
        [Helper setSlider:controllerSlider
                withValue:_controllerValue
                  minimum:0
                  maximum:127];
    }
}


@end
