//
//  AKMidiInput.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/21/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKMidiInput.h"

@implementation AKMidiInput
{
    AKParameter *_noteNumber;
    AKParameter *_frequency;
    AKParameter *_velocity;
    AKParameter *_modulation;
    AKParameter *_pitchBend;
    AKParameter *_aftertouch;
}

- (instancetype)initWithNoteNumber:(AKParameter *)noteNumber
                         frequency:(AKParameter *)frequency
                          velocity:(AKParameter *)velocity
                        modulation:(AKParameter *)modulation
                         pitchBend:(AKParameter *)pitchBend
                        aftertouch:(AKParameter *)aftertouch
{
    self = [super init];
    if (self) {
        _noteNumber = noteNumber;
        _frequency = frequency;
        _velocity = velocity;
        _modulation = modulation;
        _pitchBend = pitchBend;
        _aftertouch = aftertouch;

    }
    return self;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"midinoteonkey %@, %@\n", _noteNumber, _velocity];
    [csdString appendFormat:@"midinoteoncps %@, %@\n", _frequency, _velocity];
    [csdString appendFormat:@"%@ init 0\n", _modulation];
    [csdString appendFormat:@"midicontrolchange 1, %@, 0, 1\n", _modulation];
    [csdString appendFormat:@"%@ init 0\n", _pitchBend];
    [csdString appendFormat:@"midipitchbend %@\n", _pitchBend];
    [csdString appendFormat:@"%@ init 0\n", _aftertouch];
    [csdString appendFormat:@"midichannelaftertouch %@, 0, 1\n", _aftertouch];
    return csdString;
}

@end
