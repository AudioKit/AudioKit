//
//  MIDIController.m
//  AK Mac Examples
//
//  Created by Aurelius Prochazka on 8/13/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "MIDIController.h"
#import "AKManager.h"
#import "FivePropertyInstrument.h"
#import "AKMacTools.h"


@interface MIDIController () <AKMidiListener> {
    int _channel;
    int _note;
    int _modulation;
    int _pitchBend;
    int _controllerNumber;
    int _controllerValue;
    FivePropertyInstrument *instrument;
    AKOrchestra *orch;
    NSMutableDictionary *currentNotes;
}
@end

@implementation MIDIController

- (IBAction)enableMIDI:(id)sender {
    _channel = 1;
    _note = 0;
    _modulation = 0;
    _pitchBend = 8192;
    _controllerNumber = 0;
    _controllerValue = 0;
    
    currentNotes = [[NSMutableDictionary alloc] init];
    
    orch = [[AKOrchestra alloc] init];
    instrument = [[FivePropertyInstrument alloc] init];
    [orch addInstrument:instrument];
    
    [[AKManager sharedAKManager] runOrchestra:orch];
    [[AKManager sharedAKManager] enableMidi];
    [[[AKManager sharedAKManager] midi] addListener:self];
}

- (void)midiNoteOn:(int)note velocity:(int)velocity channel:(int)channel {
    _channel = channel;
    _note    = note;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
    FivePropertyInstrumentNote *ocsNote;
    ocsNote = [[FivePropertyInstrumentNote alloc] initWithFrequency:[AKMacTools midiNoteToFrequency:note]
                                                           atVolume:[AKMacTools scaleValue:velocity
                                                                           fromMinimum:0
                                                                           fromMaximum:127
                                                                             toMinimum:kVolumeMin
                                                                             toMaximum:kVolumeMax]];
    [instrument playNote:ocsNote];
    
    if ([currentNotes objectForKey:[NSNumber numberWithInt:note]]) {
        [self midiNoteOff:note velocity:0 channel:channel];
    }
    [currentNotes setObject:ocsNote forKey:[NSNumber numberWithInt:note]];
}

- (void)midiNoteOff:(int)note velocity:(int)velocity channel:(int)channel
{
    _channel = channel;
    _note    = note;
    AKNote *endingNote = [currentNotes objectForKey:[NSNumber numberWithInt:note]];
    [endingNote stop];
}


- (void)midiController:(int)controller changedToValue:(int)value channel:(int)channel {
    _channel = channel;
    _controllerNumber = controller;

    if (_controllerNumber > 1) {
        _controllerValue = value;
        [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
        float cutoff = [AKMacTools scaleControllerValue:value
                                        fromMinimum:kLpCutoffMax
                                          toMaximum:kLpCutoffMin];
        instrument.cutoffFrequency.value = cutoff;
    }
}

- (void)midiPitchWheel:(int)pitchWheelValue channel:(int)channel {
    _channel = channel;
    _pitchBend = pitchWheelValue;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
    
    float bend;
    if (pitchWheelValue <=8192) {
        bend = [AKMacTools scaleValue:pitchWheelValue
                      fromMinimum:0
                      fromMaximum:8192
                        toMinimum:kPitchBendMin
                        toMaximum:1];
    } else {
        bend = [AKMacTools scaleValue:pitchWheelValue
                      fromMinimum:8192
                      fromMaximum:16384
                        toMinimum:1
                        toMaximum:kPitchBendMax];
    }
    instrument.pitchBend.value = bend;
}

- (void)midiModulation:(int)modulation channel:(int)channel {
    _channel = channel;
    _modulation = modulation;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
    
    float mod = [AKMacTools scaleControllerValue:modulation
                                 fromMinimum:kModulationMin
                                   toMaximum:kModulationMax];
    instrument.modulation.value = mod;
}

- (void)updateUI {
    [_channelLabel setAttributedStringValue:[NSString stringWithFormat:@"%i", _channel]];
    [_noteLabel setAttributedStringValue:[NSString stringWithFormat:@"%i", _note]];
    
    [_modulationLabel setAttributedStringValue:[NSString stringWithFormat:@"%i", _modulation]];
    [AKMacTools setSlider:_modulationSlider
            withValue:_modulation
              minimum:0
              maximum:127];
    
    [_pitchBendLabel setAttributedStringValue:[NSString stringWithFormat:@"%i", _pitchBend]];
    [AKMacTools setSlider:_pitchBendSlider
            withValue:_pitchBend
              minimum:0
              maximum:powf(2.0, 14.0)];
    
    [_controllerNumberLabel setAttributedStringValue:[NSString stringWithFormat:@"CC# %i", _controllerNumber]];
    [_controllerValueLabel  setAttributedStringValue:[NSString stringWithFormat:@"%i", _controllerValue]];
    [AKMacTools setSlider:_controllerSlider
            withValue:_controllerValue
              minimum:0
              maximum:127];
    
}


@end
