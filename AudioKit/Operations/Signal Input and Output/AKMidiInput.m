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
    AKParameter *_velocity;
}

- (instancetype)initWithNoteNumber:(AKParameter *)noteNumber
                          Velocity:(AKParameter *)velocity;
{
    self = [super init];
    if (self) {
        _noteNumber = noteNumber;
        _velocity = velocity;

    }
    return self;
}


- (NSString *)stringForCSD
{
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"midinoteonkey %@, %@", _noteNumber, _velocity];
    return csdString;
}

@end
